// JavaScript Document

$(document).ready(function(e) {
	
	/*$("#search").keydown(function(e) {
	   $("#busca").html('<img src="load.gif" />');     	 
    });*/
	
	$("#search").keyup(function(e) {
	   var dados = $("#pesquisar").serialize();
	   jQuery.ajax({
				type: "GET", // Método passado via ajax
				url: "busca.php", //Caminho para chamar o ajax
				dataType:"html", // html, text, json.
				data:dados, //variaveis
				success:function(response){
					$("#busca").html(response);	//Coloca a mensagem do PHP na DIV resposta					
				}
		});     	 
    });	
	
});
