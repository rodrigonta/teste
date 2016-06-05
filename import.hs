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




/servico/cadastro ServicoR GET POST
/servico/checar/#ServicoxId ChecarservicoR GET




/prestador/cadastro PrestadorR GET POST
/prestador/checar/#PrestadorxId ChecarprestadorR GET




/servip/cadastro ServipR GET POST
/servip/checar/#ServipxId ChecarservipR GET



/login LogR GET POST
/logout LogoutR GET

/static StaticR Static getStatic

/erro ErroR GET



|]