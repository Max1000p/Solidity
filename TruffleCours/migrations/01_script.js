const Storage = artifacts.require("Storage");

module.exports = function (deployer) {
  // Envoi d'ether au déploiement
  const etherToSend = web3.utils.toWei("1", "ether");
  deployer.deploy(Storage, { value: etherToSend }).then(async (instance) => {
    
    console.log("Set Origine avec Constructeur" + await instance.get());
    // Appel de la fonction setVariable pour modifier la variable
    await instance.set(500);
    // Récupération des logs
    console.log('Nouveau set auto' + await instance.get());
  });
};