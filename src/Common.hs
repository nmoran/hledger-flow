{-# LANGUAGE OverloadedStrings #-}

module Common
    ( lsDirs
    , onlyDirs
    , onlyFiles
    , validDirs
    , filterPaths
    , basenameLine
    , buildFilename
    , dontSort
    , takeLast
    , firstLine
    , firstExistingFile
    ) where

import Turtle
import Prelude hiding (FilePath, putStrLn)
import Data.Text.IO (putStrLn)
import Data.Text (intercalate)
import qualified Data.List.NonEmpty as NonEmpty

lsDirs :: FilePath -> Shell FilePath
lsDirs = validDirs . ls

onlyDirs :: Shell FilePath -> Shell FilePath
onlyDirs = filterPaths isDirectory

onlyFiles :: Shell FilePath -> Shell FilePath
onlyFiles = filterPaths isRegularFile

filterPaths :: (FileStatus -> Bool) -> Shell FilePath -> Shell FilePath
filterPaths filepred files = do
  path <- files
  filestat <- stat path
  if (filepred filestat) then select [path] else select []

validDirs :: Shell FilePath -> Shell FilePath
validDirs = excludeWeirdPaths . onlyDirs

excludeWeirdPaths :: Shell FilePath -> Shell FilePath
excludeWeirdPaths = findtree (suffix $ noneOf "_")

firstExistingFile :: [FilePath] -> Shell (Maybe FilePath)
firstExistingFile files = do
  case files of
    []   -> return Nothing
    f:fs -> do
      exists <- testfile f
      if exists then return (Just f) else firstExistingFile fs

basenameLine :: FilePath -> Shell Line
basenameLine path = case (textToLine $ format fp $ basename path) of
  Nothing -> die $ format ("Unable to determine basename from path: "%fp%"\n") path
  Just bn -> return bn

buildFilename :: [Line] -> Text -> FilePath
buildFilename identifiers extension = fromText (intercalate "-" (map lineToText identifiers)) <.> extension

dontSort :: Shell FilePath -> Shell [FilePath]
dontSort files = do
  f <- files
  return [f]

takeLast :: Int -> [a] -> [a]
takeLast n = reverse . take n . reverse

firstLine :: Text -> Line
firstLine = NonEmpty.head . textToLines
