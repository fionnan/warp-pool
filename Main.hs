{-# LANGUAGE OverloadedStrings #-}

import Blaze.ByteString.Builder (copyByteString)
import Control.Monad.IO.Class
import Data.ByteString.Char8
import Data.ByteString.Lazy.Char8
import qualified Data.ByteString.UTF8 as BU
import Data.Enumerator (Iteratee)
import Data.Monoid
import Data.Pool
import qualified Database.HDBC
import qualified Database.HDBC.PostgreSQL
import Network.HTTP.Types (status200)
import Network.HTTP.Types.Header (hContentType)
import Network.Wai
import Network.Wai.Handler.Warp

main = do
    conn <- Database.HDBC.PostgreSQL.connectPostgreSQL "dbname=testdb user=lambda password=l@mbda"
    Network.Wai.Handler.Warp.run 300 (\req f -> do
        theAnswerSqlValue <- Database.HDBC.quickQuery' conn "SELECT * FROM \"Test\"" []
        let theAnswer = Database.HDBC.fromSql $ Prelude.head $ Prelude.head theAnswerSqlValue :: String
        f $ responseLBS status200 [(hContentType, Data.ByteString.Char8.pack "text/plain")] (Data.ByteString.Lazy.Char8.pack theAnswer))
