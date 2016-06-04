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

Servicox json  -- mudar para tabela n para 1 com empresa
   tipo Text
   preco Double 
   descricao Text
   deriving Show

Empresax json
   nome Text
   cnpj Text
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
/empresa/cadastro EmpresaR GET POST
/empresa/checar/#EmpresaId ChecarempresaR GET
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
           ((result, _), _) <- runFormPost formcliente
           case result of 
               FormSuccess clientex -> (runDB $ insert clientex) >>= \clid -> redirect (ChecarclienteR clid)
               _ -> redirect ErroR
           
           
           


getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|Hello World!|]


--cliente
getChecarclienteR :: ClientexId -> Handler Html
getChecarclienteR clid = do
    clientex <- runDB $ get404 clid
    defaultLayout [whamlet|
        <p><b> #{clientexNome clientex}  
        <p><b> #{clientexCpf clientex}  
        <p><b> #{clientexEndereco clientex}  
        <p><b> #{clientexTelefone clientex}  
        <p><b> #{clientexCidade clientex}  
        <p><b> #{clientexEstado clientex}  
        
    |]


getErroR :: Handler Html
getErroR = defaultLayout [whamlet|
    cadastro falhou
|]

connStr = "dbname=d73v9jtp1m4gmm host=ec2-23-21-193-140.compute-1.amazonaws.com user=wxijesuruymxxv password=olhACvaEhpoy498TfYAlN_kTYc port=5432"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       warp 8080 (Pagina pool)