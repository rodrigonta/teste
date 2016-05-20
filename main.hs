{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleInstances,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns, EmptyDataDecls #-}
import Yesod
import Database.Persist.Postgresql
import Data.Text
import Control.Monad.Logger (runStdoutLoggingT)

data Pagina = Pagina{connPool :: ConnectionPool}

instance Yesod Pagina

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Clientex json
   nome Text
   cpf Text
   endereco Text
   telefone Text
   cidade Text
   estado Text
   deriving Show

|]

mkYesod "Pagina" [parseRoutes|
/ HomeR GET
/cliente/cadastro ClienteR GET POST
/cliente/checar/#ClientexId ChecarclienteR GET
/erro ErroR GET
|]

instance YesodPersist Pagina where
   type YesodPersistBackend Pagina = SqlBackend
   runDB f = do
       master <- getYesod
       let pool = connPool master
       runSqlPool f pool

type Form a = Html -> MForm Handler (FormResult a, Widget)

instance RenderMessage Pagina FormMessage where
    renderMessage _ _ = defaultFormMessage
------------------------

-- Sempre que preciso um form, sera ncessario
-- funcoes deste tipo
formcliente :: Form Clientex
formcliente = renderDivs $ Clientex <$>
           areq textField "Nome: " Nothing <*>
           areq textField "CPF: " Nothing <*>
           areq textField "Endereço: " Nothing <*>
           areq textField "Telefone: " Nothing <*>
           areq textField "Cidade: " Nothing <*>
           areq textField "Estado: " Nothing

           

getClienteR :: Handler Html
getClienteR = do
           (widget, enctype) <- generateFormPost formcliente
           defaultLayout $ do 
           toWidget [cassius|
               label
                   color:red;
           |]
           [whamlet|
                 <form method=post enctype=#{enctype} action=@{ClienteR}>
                     ^{widget}
                     <input type="submit" value="Enviar">
           |]

postClienteR :: Handler Html
postClienteR = do
           ((((((result, _), _), _), _), _), _) <- runFormPost formcliente
           case result of 
               FormSuccess Clientex -> (runDB $ insert Clientex) >>= \clid -> redirect (ChecarclienteR clid)
               _ -> redirect ErroR
           
getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|Hello World!|]

getChecarclienteR :: ClientexId -> Handler Html
getChecarclienteR cld = do
    Clientex <- runDB $ get404 cld
    defaultLayout [whamlet|
        <p><b> #{ClientexNome Clientex}  
        <p><b> #{ClientexCpf Clientex}  
        <p><b> #{ClientexEndereco Clientex}  
        <p><b> #{ClientexTelefone Clientex}  
        <p><b> #{ClientexCidade Clientex}  
        <p><b> #{ClientexEstado Clientex}  
        
    |]

getErroR :: Handler Html
getErroR = defaultLayout [whamlet|
    cadastro falhou
|]

connStr = "dbname=dcu5a1uvm92g5f host=ec2-54-243-226-46.compute-1.amazonaws.com user=fubprkbokyfevu password=jl9JSZbmHxlGT88iUNGJQQuUwg port=5432"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       warp 8080 (Pagina pool)