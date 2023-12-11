using IO = System.IO;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using static TestDotnet.Model.ClsProduto;


// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TestDotnet.Controllers
{
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        // GET: api/values
        [HttpGet]
        //estrutura de lista
        public Root ObterProdutos()
        {
            string productsJson = IO.File.ReadAllText(@"jsonrep/produtos.json");

            Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(productsJson);

            return myDeserializedClass;
        }

   
        [HttpPost]
        public IActionResult AdicionarProduto([FromBody] EstruturaProdutos novoProduto)
        {
            string productsJson = IO.File.ReadAllText(@"jsonrep/produtos.json");
            Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(productsJson);

            int novoId = myDeserializedClass.produtos.Any() ? myDeserializedClass.produtos.Max(p => p.Iproduto) + 1 : 1;
            novoProduto.Iproduto = novoId;

            myDeserializedClass.produtos.Add(novoProduto);
            //serializar de volta para JSON
            string novoJson = JsonConvert.SerializeObject(myDeserializedClass, Formatting.Indented);
            IO.File.WriteAllText(@"jsonrep/produtos.json", novoJson);

            return CreatedAtAction(nameof(ObterProdutos), new { id = novoProduto.Iproduto }, novoProduto);
        }

        // PUT api/values/5
        //editar
        [HttpPut("{Iproduto}")]
        public IActionResult Put(int Iproduto, [FromBody] EstruturaProdutos produtoAtualizado)
        {
            string productsJson = IO.File.ReadAllText(@"jsonrep/produtos.json");
            Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(productsJson);
            //encontrar o produto
            EstruturaProdutos produtoExistente = myDeserializedClass.produtos.FirstOrDefault(p => p.Iproduto == Iproduto);

            //nao altera o id pois o id nao pode ser alterado
            produtoExistente.Nproduto = produtoAtualizado.Nproduto;
            produtoExistente.Qntproduto = produtoAtualizado.Qntproduto;
            produtoExistente.Vlrproduto = produtoAtualizado.Vlrproduto;
            produtoExistente.Ativo = produtoAtualizado.Ativo;

            //serializar de volta para Json
            string novoJson = JsonConvert.SerializeObject(myDeserializedClass, Formatting.Indented);
            IO.File.WriteAllText(@"jsonrep/produtos.json", novoJson);

            return Ok();
        }

        // DELETE api/values/5
        [HttpDelete("{Iproduto}")]
        public IActionResult Delete(int Iproduto)
        {
            //deserializar primeiro para poder tratar
            string productsJson = IO.File.ReadAllText(@"jsonrep/produtos.json");
            Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(productsJson);
            //encontrar pelo id para excluir
            EstruturaProdutos produtoParaExcluir = myDeserializedClass.produtos.FirstOrDefault(p => p.Iproduto == Iproduto);

            myDeserializedClass.produtos.Remove(produtoParaExcluir);

            string novoJson = JsonConvert.SerializeObject(myDeserializedClass, Formatting.Indented);
            IO.File.WriteAllText(@"jsonrep/produtos.json", novoJson);

            return Ok();
        }
    }
}

