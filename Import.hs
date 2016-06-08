{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}
module Import where

import Yesod
import Yesod.Static


pRoutes = [parseRoutes|

/ HomeR GET

-- cliente seria como se fosse um usuario comum
-- eles fazem login
-- talvez eu troque o nome de cliente pra usuario
/cliente/cadastro ClienteR GET POST
/cliente/checar/#ClientexId ChecarclienteR GET
/clinte/deletar/#ClientexId ExcluirclienteR GET
/cliente/listar ListarclienteR GET


-- apenas admin pode cadastrar e excluir coisas que nao sao cliente
-- usuario comum pode visualizar apenas

/empresa/cadastro EmpresaR GET POST
/empresa/checar/#EmpresaxId ChecarempresaR GET
/empresa/listar ListarempresaR GET
/empresa/deletar/#EmpresaxId ExcluirempresaR GET




/servico/cadastro ServicoR GET POST
/servico/checar/#ServicoxId ChecarservicoR GET
/servico/deletar/#ServicoxId ExcluirservicoR GET
/servico/listar/#EmpresaxId ListarservicoR GET




/prestador/cadastro PrestadorR GET POST
/prestador/checar/#PrestadorxId ChecarprestadorR GET
/prestador/listar ListarprestadorR GET
/prestador/deletar/#PrestadorxId ExcluirprestadorR GET




/servip/cadastro ServipR GET POST
/servip/checar/#ServipxId ChecarservipR GET
/servip/deletar/#ServipxId ExcluirservipR GET



/login LoginR GET POST
/logout LogoutR GET
/admin AdminR GET




/static StaticR Static getStatic

/erro ErroR GET

/js/jquery-2.1.4.min.js JqueryR GET
/js/exjquery.js ExjqueryR GET
/js/resposiveslides.min.js ResposivoR GET
|]

