/**
 * Script para importar dados de demonstração para o Firestore
 * 
 * Pré-requisitos:
 * 1. Node.js instalado
 * 2. Firebase Admin SDK configurado
 * 
 * Como usar:
 * 1. Instale as dependências: npm install firebase-admin
 * 2. Baixe a chave de serviço do seu projeto Firebase e salve como `serviceAccountKey.json`
 * 3. Execute o script: node import_to_firestore.js
 */

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// --- Configuração ---
const serviceAccount = require("./serviceAccountKey.json"); // ⚠️ Baixe do seu projeto Firebase
const dataFilePath = path.join(__dirname, "bin", "demo_data_complete.json");

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// --- Funções de Importação ---

async function importCollection(collectionName, data) {
  console.log(`🔥 Importando ${data.length} documentos para a coleção "${collectionName}"...`);
  const collectionRef = db.collection(collectionName);
  const batch = db.batch();

  data.forEach((doc) => {
    const docRef = collectionRef.doc(doc.id);
    
    // Converter datas ISO para Timestamps do Firestore
    const docData = convertDatesToTimestamp(doc);
    
    batch.set(docRef, docData);
  });

  try {
    await batch.commit();
    console.log(`✅ Coleção "${collectionName}" importada com sucesso!`);
  } catch (error) {
    console.error(`❌ Erro ao importar "${collectionName}":`, error);
  }
}

function convertDatesToTimestamp(obj) {
  const newObj = { ...obj };
  for (const key in newObj) {
    if (typeof newObj[key] === "string" && newObj[key].match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/)) {
      newObj[key] = admin.firestore.Timestamp.fromDate(new Date(newObj[key]));
    }
  }
  return newObj;
}

// --- Execução Principal ---

async function main() {
  console.log("🚀 Iniciando importação de dados de demonstração...");

  try {
    // Ler arquivo de dados completo
    const rawData = fs.readFileSync(dataFilePath, "utf-8");
    const demoData = JSON.parse(rawData);

    // Importar cada coleção
    await importCollection("projects", demoData.projects);
    await importCollection("image_records", demoData.image_records);
    await importCollection("analyses", demo_data.analyses);

    console.log("\n🎉 Todos os dados foram importados com sucesso!");
    console.log("\n📊 Resumo:");
    console.log(`  - Projetos: ${demoData.projects.length}`);
    console.log(`  - Imagens: ${demoData.image_records.length}`);
    console.log(`  - Análises: ${demoData.analyses.length}`);
    console.log("\n👉 Verifique seu console do Firebase para confirmar.");

  } catch (error) {
    console.error("❌ Erro fatal durante a importação:", error);
  }
}

main();
