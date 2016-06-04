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

-- tabelas
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Clientex json
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
   empresaid EmpresaId
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
/servico/cadastro ServicoR GET POST
/servico/checar/#ServicoId ChecarservicoR GET
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
           
           
           
           
--empresa           --
formempresa :: Form Empresax
formempresa = renderDivs $ Empresax <$>
           areq textField "Nome: " Nothing <*>
           areq textField "CNPJ: " Nothing <*>
           areq textField "Endereço: " Nothing <*>
           areq textField "Telefone: " Nothing <*>
           areq textField "Cidade: " Nothing <*>
           areq textField "Estado: " Nothing

           

getEmpresaR :: Handler Html
getEmpresaR = do
           (widget, enctype) <- generateFormPost formempresa
           defaultLayout $ do 
           toWidget [cassius|
               label
                   color:red;
           |]
           [whamlet|
                 <form method=post enctype=#{enctype} action=@{EmpresaR}>
                     ^{widget}
                     <input type="submit" value="Enviar">
           |]
           
           
postEmpresaR :: Handler Html
postEmpresaR = do
           ((result, _), _) <- runFormPost formempresa
           case result of 
               FormSuccess empresax -> (runDB $ insert empresax) >>= \emid -> redirect (ChecarempresaR emid)
               _ -> redirect ErroR
           
--serviços da empresa

empr = do
       entidades <- runDB $ selectList [] [Asc EmpresaxNome] 
       optionsPairs $ fmap (\ent -> (empresaxNome $ entityVal ent, entityKey ent)) entidades


formservico :: Form Servicox
formservico = renderDivs $ Servicox <$>
             areq textField "Tipo de serviço prestado" Nothing <*>
             areq doubleField "Preço do serviço" Nothing <*>
             areq textField "descriçao especifica do serviço" Nothing <*>
             areq (selectField empr) "Empresa" Nothing

getServicoR :: Handler Html
getServicoR = do
           (widget, enctype) <- generateFormPost formservico
           defaultLayout $ do 
           toWidget [cassius|
               label
                   color:red;
           |]
           [whamlet|
                 <form method=post enctype=#{enctype} action=@{ServicoR}>
                     ^{widget}
                     <input type="submit" value="Enviar">
           |]
           
           
postServicoR :: Handler Html
postServicoR = do
           ((result, _), _) <- runFormPost formservico
           case result of 
               FormSuccess servicox -> (runDB $ insert servicox) >>= \emid -> redirect (ChecarservicoR emid)
               _ -> redirect ErroR
           

-- home


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

--empresa
getChecarempresaR :: EmpresaxId -> Handler Html
getChecarempresaR emid = do
    empresax <- runDB $ get404 emid
    defaultLayout [whamlet|
        <p><b> #{empresaxNome empresax}  
        <p><b> #{empresaxCnpj empresax}  
        <p><b> #{empresaxEndereco empresax}  
        <p><b> #{empresaxTelefone empresax}  
        <p><b> #{empresaxCidade empresax}  
        <p><b> #{empresaxEstado empresax}  
        
    |]
    
-- servico de empresa
getChecarservicoR :: ServicoxId -> Handler Html
getChecarservicoR seid = do
    servicox <- runDB $ get404 seid
    empre <- runDB $ get404 (sevicoxEmpresaid servicox)
    defaultLayout [whamlet|
        <p> Tipo de serviço: #{servicoxTipo servicox}  
        <p> Preço: #{servicoxPreco servicox}  
        <p> Descirçao do serviço: #{servicoxDescricao servicox}
        <p> Empresa: #{empresaxNome empre}  
        
    |]
    
    
    -- erro
getErroR :: Handler Html
getErroR = defaultLayout [whamlet|
    cadastro falhou
|]

connStr = "dbname=d73v9jtp1m4gmm host=ec2-23-21-193-140.compute-1.amazonaws.com user=wxijesuruymxxv password=olhACvaEhpoy498TfYAlN_kTYc port=5432"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       warp 8080 (Pagina pool)