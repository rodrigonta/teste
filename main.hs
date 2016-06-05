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

mkYesod "Pagina" [parseRoutes|

/ HomeR GET


/cliente/cadastro ClienteR GET POST
/cliente/checar/#ClientexId ChecarclienteR GET
/clinte/deletar/#ClientexId ExcluirclienteR GET
/cliente/listar ListarclienteR GET


/empresa/cadastro EmpresaR GET POST
/empresa/checar/#EmpresaxId ChecarempresaR GET




/servico/cadastro ServicoR GET POST
/servico/checar/#ServicoxId ChecarservicoR GET




/prestador/cadastro PrestadorR GET POST
/prestador/checar/#PrestadorxId ChecarprestadorR GET




/servip/cadastro ServipR GET POST
/servip/checar/#ServipxId ChecarservipR GET




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


-- form e gets de clientes

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


getExcluirclienteR :: ClientexId -> Handler Html
getExcluirclienteR id = do
    runDB $ get404 id
    runDB $ delete $ id
    setMessage $ [shamlet| Registro excluído com sucesso! |]
    redirect ListarclienteR



getListarclienteR :: Handler Html
getListarclienteR = do
    lista <- runDB $ selectList [] [Asc ClientexNome]
    msg <- getMessage
    defaultLayout $ do
        setTitle "Lista de Clientes"
--arrumar a pagina de listar




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
           


getChecarservicoR :: ServicoxId -> Handler Html
getChecarservicoR seid = do
    servicox <- runDB $ get404 seid
    empre <- runDB $ get404 (servicoxEmpresaid servicox)
    defaultLayout [whamlet|
        <p> Tipo de serviço: #{servicoxTipo servicox}  
        <p> Preço: #{servicoxPreco servicox}  
        <p> Descirçao do serviço: #{servicoxDescricao servicox}
        <p> Empresa: #{empresaxNome empre}  
        
    |]





--prestador de servico
formprestador :: Form Prestadorx
formprestador = renderDivs $ Prestadorx <$>
           areq textField "Nome: " Nothing <*>
           areq textField "CPF: " Nothing <*>
           areq textField "Endereço: " Nothing <*>
           areq textField "Telefone: " Nothing <*>
           areq textField "Cidade: " Nothing <*>
           areq textField "Estado: " Nothing



getPrestadorR :: Handler Html
getPrestadorR = do
           (widget, enctype) <- generateFormPost formprestador
           defaultLayout $ do 
           toWidget [cassius|
               label
                   color:red;
           |]
           [whamlet|
                 <form method=post enctype=#{enctype} action=@{PrestadorR}>
                     ^{widget}
                     <input type="submit" value="Enviar">
           |]
           


postPrestadorR :: Handler Html
postPrestadorR = do
           ((result, _), _) <- runFormPost formprestador
           case result of 
               FormSuccess prestadorx -> (runDB $ insert prestadorx) >>= \preid -> redirect (ChecarprestadorR preid)
               _ -> redirect ErroR
           


getChecarprestadorR :: PrestadorxId -> Handler Html
getChecarprestadorR preid = do
    prestadorx <- runDB $ get404 preid
    defaultLayout [whamlet|
        <p><b> #{prestadorxNome prestadorx}  
        <p><b> #{prestadorxCpf prestadorx}  
        <p><b> #{prestadorxEndereco prestadorx}  
        <p><b> #{prestadorxTelefone prestadorx}  
        <p><b> #{prestadorxCidade prestadorx}  
        <p><b> #{prestadorxEstado prestadorx}  
        
    |]



--serviços do prestador

pres = do
       entidades <- runDB $ selectList [] [Asc PrestadorxNome] 
       optionsPairs $ fmap (\ent -> (prestadorxNome $ entityVal ent, entityKey ent)) entidades


formservip :: Form Servipx
formservip = renderDivs $ Servipx <$>
             areq textField "Tipo de serviço prestado" Nothing <*>
             areq doubleField "Preço do serviço" Nothing <*>
             areq textField "descriçao especifica do serviço" Nothing <*>
             areq (selectField pres) "Prestador" Nothing

getServipR :: Handler Html
getServipR = do
           (widget, enctype) <- generateFormPost formservip
           defaultLayout $ do 
           toWidget [cassius|
               label
                   color:red;
           |]
           [whamlet|
                 <form method=post enctype=#{enctype} action=@{ServipR}>
                     ^{widget}
                     <input type="submit" value="Enviar">
           |]
           
           
postServipR :: Handler Html
postServipR = do
           ((result, _), _) <- runFormPost formservip
           case result of 
               FormSuccess servipx -> (runDB $ insert servipx) >>= \preid -> redirect (ChecarservipR preid)
               _ -> redirect ErroR
           

getChecarservipR :: ServipxId -> Handler Html
getChecarservipR seid = do
    servipx <- runDB $ get404 seid
    prest <- runDB $ get404 (servipxPrestadorid servipx)
    defaultLayout [whamlet|
        <p> Tipo de serviço: #{servipxTipo servipx}  
        <p> Preço: #{servipxPreco servipx}  
        <p> Descirçao do serviço: #{servipxDescricao servipx}
        <p> Prestador: #{prestadorxNome prest}  
        
    |]












-- home


getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|Hello World!|]





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