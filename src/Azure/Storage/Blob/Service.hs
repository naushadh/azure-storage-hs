{-# LANGUAGE OverloadedStrings #-}

module Azure.Storage.Blob.Service where

import qualified Azure.Storage.Blob.Types as Types
import qualified Azure.Storage.Types as Types
import qualified Azure.Storage.Request as Request
import qualified Azure.Storage.Authentication as Auth
import qualified Network.HTTP.Client as HTTP
import           Control.Monad.Except (liftIO, MonadIO)
import qualified Data.Either as Either

issueRequest
  :: (Request.ToRequest blobReq, Request.FromResponse a, MonadIO m)
  => Types.Client -> blobReq -> m (Either (Types.Error, Request.Response) a)
issueRequest client blobReq = do
  let creds = Types.blobCreds client
  let mgr = Types.blobHttp client
  let reqUnsigned = Request.createRequest blobReq $ Types.blobReq client

  request <- Auth.signRequest creds reqUnsigned
  responseRaw <- liftIO (HTTP.httpLbs request mgr)
  let responseParsed = Request.parseResponse responseRaw
  let response = Either.either (\e -> Left $ (e,responseRaw)) Right responseParsed

  return response
