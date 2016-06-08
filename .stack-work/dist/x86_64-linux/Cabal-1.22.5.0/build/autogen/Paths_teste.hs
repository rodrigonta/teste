module Paths_teste (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/ubuntu/workspace/teste/.stack-work/install/x86_64-linux/lts-5.12/7.10.3/bin"
libdir     = "/home/ubuntu/workspace/teste/.stack-work/install/x86_64-linux/lts-5.12/7.10.3/lib/x86_64-linux-ghc-7.10.3/teste-0.0.0-Dtayffv3HIb0i5Qe7sr1yN"
datadir    = "/home/ubuntu/workspace/teste/.stack-work/install/x86_64-linux/lts-5.12/7.10.3/share/x86_64-linux-ghc-7.10.3/teste-0.0.0"
libexecdir = "/home/ubuntu/workspace/teste/.stack-work/install/x86_64-linux/lts-5.12/7.10.3/libexec"
sysconfdir = "/home/ubuntu/workspace/teste/.stack-work/install/x86_64-linux/lts-5.12/7.10.3/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "teste_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "teste_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "teste_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "teste_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "teste_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
