namespace TestDotnet.Model;
using System.IO;
using Newtonsoft.Json;

public class ClsProduto
{
    public class EstruturaProdutos
    {
        public int Iproduto { get; set; }
        public string Nproduto { get; set; }
        public decimal Qntproduto { get; set; }
        public double Vlrproduto { get; set; }
        public bool Ativo { get; set; }

    }

    // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);

    public class Root
    {
        public List<EstruturaProdutos> produtos { get; set; }
    }
}



