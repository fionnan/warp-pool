{-# LANGUAGE OverloadedStrings #-}

import           Data.ByteString.Lazy.Char8 as LBS
import           Database.HDBC as H
import           Database.HDBC.PostgreSQL as HP
import           Network.HTTP.Types         (status200)
import           Network.HTTP.Types.Header  (hContentType)
import           Network.Wai
import           Network.Wai.Handler.Warp as W

main :: IO()
main = do
    conn <- HP.connectPostgreSQL "dbname=testdb user=lambda password=l@mbda"
    W.run 3000 (\_ f -> do
        theAnswerSqlValue <- H.quickQuery' conn "SELECT * FROM \"Test\"" []
        let theAnswer = fromSql $ Prelude.head $ Prelude.head theAnswerSqlValue :: String
        f $ responseLBS status200 [(hContentType, "text/plain")] (LBS.pack theAnswer))