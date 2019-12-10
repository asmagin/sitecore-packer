#load "src/core/cake/core.cake"

var target = Argument("target", "default");
var configuration = Argument("configuration", string.Empty);
var recursive = Argument("recursive", false);

packerTemplates = new List<PackerTemplate>();

var w16s = PackerTemplates_Create("w16s", amazon: true);
var w16s_dotnet = PackerTemplates_Create("w16s-dotnet", parents: w16s);
var w16s_iis = PackerTemplates_Create("w16s-iis", parents: w16s_dotnet);

var w16s_sql16d = PackerTemplates_Create("w16s-sql16d", parents: w16s_iis);

var w16s_solr662 = PackerTemplates_Create("w16s-solr662", parents: w16s_sql16d);
var w16s_solr721 = PackerTemplates_Create("w16s-solr721", parents: w16s_sql16d);
var w16s_solr750 = PackerTemplates_Create("w16s-solr750", parents: w16s_sql16d);
var w16s_solr811 = PackerTemplates_Create("w16s-solr811", parents: w16s_sql16d);

var w16s_sc900 = PackerTemplates_Create("w16s-sc900", parents: w16s_solr662);

var w16s_sc901 = PackerTemplates_Create("w16s-sc901", parents: w16s_solr662);

var w16s_sc902 = PackerTemplates_Create("w16s-sc902", parents: w16s_solr662);
var w16s_sc902_jss1100 = PackerTemplates_Create("w16s-sc902_jss1100", parents: w16s_sc902);
var w16s_sc902_sxa171_jss1100 = PackerTemplates_Create("w16s-sc902_sxa171_jss1100", parents: w16s_sc902);
var w16s_sc902_sxa180 = PackerTemplates_Create("w16s-sc902_sxa180", parents: w16s_sc902);
var w16s_sc902_sxa180_jss1100 = PackerTemplates_Create("w16s-sc902_sxa180_jss1100", parents: w16s_sc902);

var w16s_sc910 = PackerTemplates_Create("w16s-sc910", parents: w16s_solr721);
var w16s_sc910_sxa180 = PackerTemplates_Create("w16s-sc910_sxa180", parents: w16s_sc910);
var w16s_sc910_jss1100 = PackerTemplates_Create("w16s-sc910_jss1100", parents: w16s_sc910);
var w16s_sc910_sxa180_jss1100 = PackerTemplates_Create("w16s-sc910_sxa180_jss1100", parents: w16s_sc910);

var w16s_sc911 = PackerTemplates_Create("w16s-sc911", parents: w16s_solr721);
var w16s_sc911_sxa181 = PackerTemplates_Create("w16s-sc911_sxa181", parents: w16s_sc911);
var w16s_sc911_jss1101 = PackerTemplates_Create("w16s-sc911_jss1101", parents: w16s_sc911);
var w16s_sc911_jss1110 = PackerTemplates_Create("w16s-sc911_jss1110", parents: w16s_sc911);
var w16s_sc911_sxa181_jss1101 = PackerTemplates_Create("w16s-sc911_sxa181_jss1101", parents: w16s_sc911);
var w16s_sc911_sxa181_jss1110 = PackerTemplates_Create("w16s-sc911_sxa181_jss1110", parents: w16s_sc911);

var w16s_sc920 = PackerTemplates_Create("w16s-sc920", parents: w16s_solr750);
var w16s_sc920_sxa190 = PackerTemplates_Create("w16s-sc920_sxa190", parents: w16s_sc920);
var w16s_sc920_jss1200 = PackerTemplates_Create("w16s-sc920_jss1200", parents: w16s_sc920);
var w16s_sc920_sxa190_jss1200 = PackerTemplates_Create("w16s-sc920_sxa190_jss1200", parents: w16s_sc920);

var w16s_xc901 = PackerTemplates_Create("w16s-xc901", parents: w16s_sc901);

var w16s_xc902 = PackerTemplates_Create("w16s-xc902", parents: w16s_sc902);

var w16s_xc903 = PackerTemplates_Create("w16s-xc903", parents: w16s_sc902);
var w16s_xc903_sxa180_storefront = PackerTemplates_Create("w16s-xc903_sxa180_storefront", parents: w16s_sc902_sxa180);

var w16s_xc910 = PackerTemplates_Create("w16s-xc910", parents: w16s_sc911);
var w16s_xc910_sxa181_storefront = PackerTemplates_Create("w16s-xc910_sxa181_storefront", parents: w16s_sc911);

packerTemplates = packerTemplates.
  Concat(w16s).
  Concat(w16s_dotnet).
  Concat(w16s_iis).
  Concat(w16s_sql16d).
  Concat(w16s_solr662).
  Concat(w16s_solr721).
  Concat(w16s_solr750).
  Concat(w16s_solr811).
  Concat(w16s_sc900).
  Concat(w16s_sc901).
  Concat(w16s_sc902).
  Concat(w16s_sc902_jss1100).
  Concat(w16s_sc902_sxa171_jss1100).
  Concat(w16s_sc902_sxa180).
  Concat(w16s_sc902_sxa180_jss1100).
  Concat(w16s_sc910).
  Concat(w16s_sc910_sxa180).
  Concat(w16s_sc910_jss1100).
  Concat(w16s_sc910_sxa180_jss1100).
  Concat(w16s_sc911).
  Concat(w16s_sc911_sxa181).
  Concat(w16s_sc911_jss1101).
  Concat(w16s_sc911_jss1110).
  Concat(w16s_sc911_sxa181_jss1101).
  Concat(w16s_sc911_sxa181_jss1110).
  Concat(w16s_sc920).
  Concat(w16s_sc920_sxa190).
  Concat(w16s_sc920_jss1200).
  Concat(w16s_sc920_sxa190_jss1200).
  Concat(w16s_xc901).
  Concat(w16s_xc902).
  Concat(w16s_xc903).
  Concat(w16s_xc903_sxa180_storefront).
  Concat(w16s_xc910).
  Concat(w16s_xc910_sxa181_storefront).
  ToList();

packerTemplate = configuration;
packerRecursive = recursive;

IEnumerable<PackerTemplate> PackerTemplates_Create(string type, bool amazon = false, IEnumerable<PackerTemplate> parents = null) {
  var items = new List<PackerTemplate>();

  var virtualBoxCore = PackerTemplate_Create(
    type,
    "virtualbox-core",
    new [] { PackerBuilder_Create(parents == null ? "virtualbox-iso" : "virtualbox-ovf") },
    new [] { PackerProvisioner_Create("chef") },
    new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
    parents != null ? parents.First(item => item.IsMatching("virtualbox-core")) : null
  );
  // var virtualBoxSysprep = PackerTemplate_Create(
  //   type,
  //   "virtualbox-sysprep",
  //   new [] { PackerBuilder_Create("virtualbox-ovf") },
  //   new [] { PackerProvisioner_Create("sysprep") },
  //   new [] { PackerPostProcessor_Create("vagrant-virtualbox") },
  //   virtualBoxCore
  // );
  items.Add(virtualBoxCore);
  // items.Add(virtualBoxSysprep);

  return items;
}

Task("default")
  .IsDependentOn("info");

Task("info")
  .IsDependentOn("packer-info");

Task("clean")
  .IsDependentOn("packer-clean");

Task("version")
  .IsDependentOn("packer-version");

Task("restore")
  .IsDependentOn("packer-restore");

Task("build")
  .IsDependentOn("packer-build");

Task("rebuild")
  .IsDependentOn("packer-rebuild");

Task("test")
  .IsDependentOn("packer-test");

Task("package")
  .IsDependentOn("packer-package");

Task("publish")
  .IsDependentOn("packer-publish");

RunTarget(target);
