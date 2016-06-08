{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns #-}

module DBA where

import Import
import Yesod
import Yesod.Static
import Data.Text
import Database.Persist.Postgresql
    ( ConnectionPool, SqlBackend, runSqlPool, runMigration )

data Pagina = Pagina{connPool :: ConnectionPool,
                     getStatic :: Static }

staticFiles "."


-- tabelas
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Clientex json
   username Text
   UniqueUsername username
   senha Text
   nome Text
   cpf Text
   endereco Text
   telefone Text
   cidade Text
   estado Text
   deriving Show

Servicox json
   tipo Text
   preco Double 
   descricao Text
   empresaid EmpresaxId
   deriving Show

Empresax json
   nome Text
   cnpj Text
   endereco Text
   telefone Text
   cidade Text
   estado Text
   deriving Show
   
Servipx json
   tipo Text
   preco Double 
   descricao Text
   prestadorid PrestadorxId
   deriving Show

Prestadorx json
   nome Text
   cpf Text
   endereco Text
   telefone Text
   cidade Text
   estado Text
   deriving Show

|]



mkYesodData "Pagina" pRoutes

instance YesodPersist Pagina where
   type YesodPersistBackend Pagina = SqlBackend
   runDB f = do 
       master <- getYesod
       let pool = connPool master
       runSqlPool f pool

instance Yesod Pagina where
    authRoute _ = Just $ HomeR
    isAuthorized EmpresaR _ = isAdmin
--    isAuthorized ExcluirempresaR _ = isAdmin
    isAuthorized ServicoR _ = isAdmin
--    isAuthorized ExcluirservicoR _ = isAdmin
    isAuthorized PrestadorR _ = isAdmin
--    isAuthorized ExcluirprestadorR _ = isAdmin
    isAuthorized ServipR _ = isAdmin
--    isAuthorized ExcluirservipR _ = isAdmin
    isAuthorized ListarclienteR _ = isUser
    isAuthorized _ _ = return Authorized

isAdmin = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired
        Just "admin" -> Authorized
        Just _ -> Unauthorized "Apenas admin acessa aqui"

isUser = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired 
        Just _ -> Authorized

type Form a = Html -> MForm Handler (FormResult a, Widget)

instance RenderMessage Pagina FormMessage where
    renderMessage _ _ = defaultFormMessage