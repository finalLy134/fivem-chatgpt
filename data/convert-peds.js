const fs = require("fs");

const allPeds = JSON.parse(fs.readFileSync("peds.json"));

const humanPeds = {};

allPeds.forEach((ped) => {
  console.log(`Parsing ${ped.Name}.`);

  const pedType = ped.Pedtype.toLowerCase();
  const personality = ped.Personality;

  if (!["civmale", "civfemale"].includes(pedType)) {
    return;
  }

  humanPeds[ped.SignedHash] = {
    name: ped.Name,
    gender: pedType === "civmale" ? "Male" : "Female",
    personality: personality || "Generic",
  };
});

fs.writeFileSync("human-peds.json", JSON.stringify(humanPeds));

console.log("Done.");
