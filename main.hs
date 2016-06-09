{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleInstances,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns, EmptyDataDecls #-}




import Yesod
import Database.Persist.Postgresql
import Data.Text
import Data.Time
import qualified Data.Text as T
import Yesod
import Yesod.Static
import Yesod.Form.Bootstrap3
import Control.Applicative
import Data.Monoid
import Text.Lucius
import Text.Julius
import Text.Hamlet
import DBA
import Import
import Yesod.Form.Jquery

import Control.Monad.Logger (runStdoutLoggingT)


mkYesodDispatch "Pagina" pRoutes


------------------------
-- Sempre que preciso um form, sera ncessario
-- funcoes deste tipo


-- form e gets de clientes

formcliente :: Form Clientex
formcliente = renderDivs $ Clientex <$>
           areq textField "Login: " Nothing <*>
           areq passwordField "Senha: " Nothing <*>
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
                   color:green;
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
               FormSuccess clientex -> (runDB $ insert clientex) >>= \clid -> redirect (LoginR)
               _ -> redirect ErroR
           

    
getChecarclienteR :: ClientexId -> Handler Html
getChecarclienteR clid = do
    clientex <- runDB $ get404 clid
    defaultLayout [whamlet|
        <p><b> #{clientexUsername clientex}  
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
        $(whamletFile "hamlets/clientes/listarcliente.hamlet")
        addStylesheet $ StaticR css_menu_css
        addScript JqueryR
        addScript ExjqueryR
        addScript ResposivoR
        toWidget $(juliusFile "julius/index.julius")
        toWidget [cassius|
                h2
                    color:#00c0ac;
                tbody
                    a:link 
                        color: black
                    a:visited 
                        color: black
                    a:hover 
                        color: black
                    a:active 
                        color: black
        |]


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



getExcluirempresaR :: EmpresaxId -> Handler Html
getExcluirempresaR id = do
    runDB $ get404 id
    runDB $ delete $ id
    setMessage $ [shamlet| Registro excluído com sucesso! |]
    redirect ListarempresaR




getListarempresaR :: Handler Html
getListarempresaR = do
    lista <- runDB $ selectList [] [Asc EmpresaxNome]
    msg <- getMessage
    defaultLayout $ do
        setTitle "Lista de Empresas"
        $(whamletFile "hamlets/empresa/listarempresa.hamlet")
        addStylesheet $ StaticR css_menu_css
        addScript JqueryR
        addScript ExjqueryR
        addScript ResposivoR
        toWidget $(juliusFile "julius/index.julius")
        toWidget [cassius|
                h2
                    color:#00c0ac;
                tbody
                    a:link 
                        color: black
                    a:visited 
                        color: black
                    a:hover 
                        color: black
                    a:active 
                        color: black
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



getExcluirservicoR :: ServicoxId -> Handler Html
getExcluirservicoR id = do
    runDB $ get404 id
    empre <- runDB $ delete $ id
    setMessage $ [shamlet| Registro excluído com sucesso! |]
    redirect ListarempresaR




getListarservicoR :: EmpresaxId -> Handler Html
getListarservicoR id = do
    lista <- runDB $ selectList [] [Asc ServicoxTipo]
    msg <- getMessage
    defaultLayout $ do
        setTitle "Lista de Serviços"
        $(whamletFile "hamlets/empresa/listarservico.hamlet")
        addStylesheet $ StaticR css_menu_css
        addScript JqueryR
        addScript ExjqueryR
        addScript ResposivoR
        toWidget $(juliusFile "julius/index.julius")
        toWidget [cassius|
                h2
                    color:#00c0ac;
                tbody
                    a:link 
                        color: black
                    a:visited 
                        color: black
                    a:hover 
                        color: black
                    a:active 
                        color: black
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



getExcluirprestadorR :: PrestadorxId -> Handler Html
getExcluirprestadorR id = do
    runDB $ get404 id
    runDB $ delete $ id
    setMessage $ [shamlet| Registro excluído com sucesso! |]
    redirect ListarprestadorR



getListarprestadorR :: Handler Html
getListarprestadorR = do
    lista <- runDB $ selectList [] [Asc PrestadorxNome]
    msg <- getMessage
    defaultLayout $ do
        setTitle "Lista de Prestadores"
        $(whamletFile "hamlets/prestador/listarprestador.hamlet")
        addStylesheet $ StaticR css_menu_css
        addScript JqueryR
        addScript ExjqueryR
        addScript ResposivoR
        toWidget $(juliusFile "julius/index.julius")
        toWidget [cassius|
                h2
                    color:#00c0ac;
                tbody
                    a:link 
                        color: black
                    a:visited 
                        color: black
                    a:hover 
                        color: black
                    a:active 
                        color: black
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

getExcluirservipR :: ServipxId -> Handler Html
getExcluirservipR id = do
    runDB $ get404 id
    prest <- runDB $ delete $ id
    setMessage $ [shamlet| Registro excluído com sucesso! |]
    redirect ListarprestadorR


getListarservipR :: PrestadorxId -> Handler Html
getListarservipR id = do
    lista <- runDB $ selectList [] [Asc ServipxTipo]
    msg <- getMessage
    defaultLayout $ do
        setTitle "Lista de Serviços"
        $(whamletFile "hamlets/prestador/listarservip.hamlet")
        addStylesheet $ StaticR css_menu_css
        addScript JqueryR
        addScript ExjqueryR
        addScript ResposivoR
        toWidget $(juliusFile "julius/index.julius")
        toWidget [cassius|
                h2
                    color:#00c0ac;
                tbody
                    a:link 
                        color: black
                    a:visited 
                        color: black
                    a:hover 
                        color: black
                    a:active 
                        color: black
        |]





-- home


getHomeR :: Handler Html
getHomeR = do
        --lista <- runDB $ selectList [] [Asc EmpresaNome]
        defaultLayout $ do
            setTitle "Mew Festas"
            $(whamletFile "hamlets/home/index.hamlet")
            addStylesheet $ StaticR css_menu_css
            addScript JqueryR
            addScript ExjqueryR
            addScript ResposivoR
            toWidget $(juliusFile "julius/index.julius")

getLoginR :: Handler Html
getLoginR = do
           deleteSession "_ID"
           (widget, enctype) <- generateFormPost formLogin
           defaultLayout [whamlet|
                 <form method=post enctype=#{enctype} action=@{LoginR}>
                     ^{widget}
                     <input type="submit" value="Login">
          |]
          
          



formLogin :: Form (Text,Text)
formLogin = renderDivs $ (,) <$>
           areq textField "Login: " Nothing <*>
           areq passwordField "Senha: " Nothing
         


postLoginR :: Handler Html
postLoginR = do
           ((result, _), _) <- runFormPost formLogin
           case result of 
               FormSuccess ("admin","admin") -> setSession "_ID" "admin" >> redirect AdminR
               FormSuccess (login,senha) -> do 
                   user <- runDB $ selectFirst [ClientexUsername ==. login, ClientexSenha ==. senha] []
                   case user of
                       Nothing -> redirect ErroR
                       Just (Entity pid u) -> setSession "_ID" (pack $ show $ fromSqlKey pid) >> redirect (ChecarclienteR pid)
               _ -> redirect ErroR



getAdminR :: Handler Html
getAdminR = defaultLayout [whamlet|
     <h1> Seja bem vindo administrador!
|]

getLogoutR :: Handler Html
getLogoutR = do
     deleteSession "_ID"
     defaultLayout [whamlet| 
         <h1> Xauzinho!
     |]



    -- erro
getErroR :: Handler Html
getErroR = defaultLayout [whamlet|
    <h1>falhou
|]

getJqueryR :: Handler ()
getJqueryR  = sendFile "text/javascript" "js/jquery-2.1.4.min.js"

getExjqueryR :: Handler ()
getExjqueryR = sendFile "text/javascript" "js/exjquery.js"

getResposivoR :: Handler ()
getResposivoR = sendFile "text/javascript" "js/resposiveslides.min.js"

connStr = "dbname=d73v9jtp1m4gmm host=ec2-23-21-193-140.compute-1.amazonaws.com user=wxijesuruymxxv password=olhACvaEhpoy498TfYAlN_kTYc port=5432"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       s <- static "static"
       warp 8080 (Pagina pool s)
       
       