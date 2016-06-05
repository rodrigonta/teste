{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}
module Routers where

import Yesod
import Yesod.Static

mkYesod "Pagina" [parseRoutes|

/ HomeR GET


/cliente/cadastro ClienteR GET POST
/cliente/checar/#ClientexId ChecarclienteR GET
/clinte/deletar/#ClientexId ExcluirclienteR GET
/cliente/listar ListarclienteR GET


/empresa/cadastro EmpresaR GET POST
/empresa/checar/#EmpresaxId ChecarempresaR GET
/empresa/deletar/#EmpresaxId ExcluirempresaR GET
/empresa/listar ListarempresaR GET


/servico/cadastro ServicoR GET POST
/servico/checar/#ServicoxId ChecarservicoR GET
/servico/deletar/#ServicoxId ExcluirservicoR GET
/servico/listar ListarservicoR GET


/prestador/cadastro PrestadorR GET POST
/prestador/checar/#PrestadorxId ChecarprestadorR GET
/prestador/deletar/#PrestadorxId ExcluirprestadorR GET
/prestador/listar ListarprestadorR GET


/servip/cadastro ServipR GET POST
/servip/checar/#ServipxId ChecarservipR GET
/servip/deletar/#ServipxId ExcluirservipR GET
/servip/listar ListarservipR GET




/login LoginR GET POST
/logout LogoutR GET
/admin AdminR GET




/erro ErroR GET



|]
