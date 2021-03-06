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

staticFiles "static"


-- tabelas
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
--tabela de clientes
--com username unico pra cada cliente
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


--servico de empresa
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


--servico de prestador
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




--parte que diz quais rotas sao acessadas por qualquer um,
--apenas por usuários, ou apenas por admin

instance Yesod Pagina where
--    authRoute _ = Just $ HomeR
    isAuthorized EmpresaR _ = isAdmin
    isAuthorized (ExcluirempresaR _) _writable = isAdmin
    isAuthorized ServicoR _ = isAdmin
    isAuthorized (ExcluirservicoR _) _writable = isAdmin
    isAuthorized PrestadorR _ = isAdmin
    isAuthorized (ExcluirprestadorR _) _writable = isAdmin
    isAuthorized ServipR _ = isAdmin
    isAuthorized (ExcluirservipR _) _writable = isAdmin
    isAuthorized HomeR _ = return Authorized
    isAuthorized ClienteR _ = return Authorized
    isAuthorized LoginR _ = return Authorized
    isAuthorized ErroR _ = return Authorized
    isAuthorized JqueryR _ = return Authorized
    isAuthorized ExjqueryR _ = return Authorized
    isAuthorized ResposivoR _ = return Authorized
    isAuthorized _ _ = isUser



--checa na sessao se o usuario logado eh admin
isAdmin = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired
        Just "admin" -> Authorized
        Just _ -> Unauthorized "Apenas admin acessa aqui"
--ou se eh usuario comum
isUser = do
    mu <- lookupSession "_ID"
    return $ case mu of
        Nothing -> AuthenticationRequired 
        Just _ -> Authorized

type Form a = Html -> MForm Handler (FormResult a, Widget)

instance RenderMessage Pagina FormMessage where
    renderMessage _ _ = defaultFormMessage