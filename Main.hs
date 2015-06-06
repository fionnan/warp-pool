{-# LANGUAGE OverloadedStrings #-}
import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types (status200)
import Blaze.ByteString.Builder (copyByteString)
import qualified Data.ByteString.UTF8 as BU
import Data.Monoid
import Data.Enumerator (Iteratee)
import Data.Pool
import qualified Database.HDBC as H
import qualified Database.HDBC.PostgreSQL as HP
import Control.Monad.IO.Class

main = do
    let port = 3000
    putStrLn $ "Listening on port " ++ show port
    createPool (HP.connectPostgreSQL "dbname=haskell_api") H.disconnect 5 $ \pool -> run port .app

--5 $ run port . app

app::Pool HP.Connection -> Application
app pool req = do
    case pathInfo req of
        ["reports"] ->
          liftIO $ withResource pool reports
        x -> return $ index x

reports conn = do
  reports <- H.quickQuery' conn "SELECT * from things" []
  return $ responseBuilder status200 [ ("Content-Type", "text/plain") ] $ mconcat $ map copyByteString
    [ "yay" ]

index x = responseBuilder status200 [("Content-Type", "text/html")] $ mconcat $ map copyByteString
    [ "<p>Hello from ", BU.fromString $ show x, "!</p>"
    , "<p><a href='/yay'>yay</a></p>\n" ]
