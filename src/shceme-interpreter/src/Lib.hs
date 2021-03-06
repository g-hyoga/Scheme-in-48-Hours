module Lib
    ( someFunc 
    ) where
import System.Environment
import Text.ParserCombinators.Parsec hiding (spaces)
import Control.Monad

symbol :: Parser Char
symbol = oneOf "!#$%|*+-/:<=>?@^_\n\r\t\\~"

readExpr :: String -> String
readExpr input = case parse parseExpr "lisp" input of
    Left err -> "No match:" ++ show err
    Right _ -> "Found value"
 
spaces :: Parser()
spaces = skipMany1 space

data LispVal = Atom String
    |List [LispVal]
    |DottedList [LispVal]LispVal
    |Number Integer
    |String String
    |Bool Bool

parseString :: Parser LispVal
parseString = do
    char '"'
    x <- many(noneOf("\""))
    char '"'
    return $ String x

parseAtom :: Parser LispVal
parseAtom = do
    first <- letter <|> symbol
    rest <- many (letter <|> digit <|> symbol)
    let atom = first:rest
    return $ case atom of
        "#t" -> Bool True
        "#f" -> Bool False
        _ -> Atom atom

parseNumber :: Parser LispVal
parseNumber = many1 digit >>= return . Number . read

parseExpr :: Parser LispVal
parseExpr = parseAtom
    <|> parseString
    <|> parseNumber
    <|> parseQuoted
    <|> do 
        char '('
        x <- try parseList <|> parseDottedList
        char ')'
        return x

parseList :: Parser LispVal
parseList = sepBy parseExpr spaces >>= return . List 

parseDottedList :: Parser LispVal
parseDottedList = do
    head <- endBy parseExpr spaces
    tail <- char '.' >> spaces >> parseExpr
    return $ DottedList head tail

parseQuoted :: Parser LispVal
parseQuoted = do
    char '\''
    x <- parseExpr
    return $ List[Atom "quote", x]

someFunc :: IO ()
someFunc = do
    args <- getArgs
    print(readExpr(args !! 0))


