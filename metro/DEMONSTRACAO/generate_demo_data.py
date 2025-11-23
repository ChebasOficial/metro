#!/usr/bin/env python3
import json
import base64
import os
from datetime import datetime

def load_image_base64(image_path):
    """Carrega imagem e retorna base64"""
    with open(image_path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

def generate_demo_data():
    """Gera dados de demonstração com imagens em base64"""
    
    # Diretórios
    images_dir = 'images'
    data_dir = 'data'
    bin_dir = 'bin'
    
    # Carregar imagens em base64
    print("📸 Carregando imagens...")
    images_b64 = {}
    for i in range(1, 5):
        img_file = f'obra{i}_*.jpg'
        img_path = None
        for f in os.listdir(images_dir):
            if f.startswith(f'obra{i}_') and f.endswith('.jpg'):
                img_path = os.path.join(images_dir, f)
                break
        
        if img_path:
            images_b64[f'OBRA{i}'] = load_image_base64(img_path)
            print(f"  ✅ Imagem {i} carregada ({len(images_b64[f'OBRA{i}'])} bytes)")
    
    # Carregar JSONs
    print("\n📄 Processando dados JSON...")
    with open(os.path.join(data_dir, 'projects.json'), 'r', encoding='utf-8') as f:
        projects = json.load(f)
    
    with open(os.path.join(data_dir, 'image_records.json'), 'r', encoding='utf-8') as f:
        image_records_template = f.read()
    
    with open(os.path.join(data_dir, 'analyses.json'), 'r', encoding='utf-8') as f:
        analyses = json.load(f)
    
    # Substituir placeholders de base64 nas image_records
    print("\n🔄 Inserindo base64 nas imagens...")
    image_records_str = image_records_template
    image_records_str = image_records_str.replace('<BASE64_OBRA1>', images_b64['OBRA1'])
    image_records_str = image_records_str.replace('<BASE64_OBRA2>', images_b64['OBRA2'])
    image_records_str = image_records_str.replace('<BASE64_OBRA3>', images_b64['OBRA3'])
    image_records_str = image_records_str.replace('<BASE64_OBRA4>', images_b64['OBRA4'])
    
    image_records = json.loads(image_records_str)
    
    # Criar estrutura de dados completa
    demo_data = {
        'projects': projects,
        'image_records': image_records,
        'analyses': analyses,
        'metadata': {
            'generated_at': datetime.now().isoformat(),
            'version': '2.0.5',
            'total_projects': len(projects),
            'total_images': len(image_records),
            'total_analyses': len(analyses)
        }
    }
    
    # Salvar dados completos em JSON
    print("\n💾 Salvando dados completos...")
    output_json = os.path.join(bin_dir, 'demo_data_complete.json')
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(demo_data, f, ensure_ascii=False, indent=2)
    
    file_size_mb = os.path.getsize(output_json) / (1024 * 1024)
    print(f"  ✅ Arquivo salvo: {output_json} ({file_size_mb:.2f} MB)")
    
    # Salvar dados separados (sem base64 completo para facilitar visualização)
    print("\n💾 Salvando dados separados...")
    
    # Projects
    with open(os.path.join(bin_dir, 'projects.bin.json'), 'w', encoding='utf-8') as f:
        json.dump(projects, f, ensure_ascii=False, indent=2)
    print(f"  ✅ projects.bin.json")
    
    # Image records (com referência às imagens)
    image_records_ref = []
    for i, record in enumerate(image_records, 1):
        record_copy = record.copy()
        record_copy['imageBase64'] = f'[BASE64_DATA_{i}]'
        record_copy['imageUrl'] = f'data:image/jpeg;base64,[BASE64_DATA_{i}]'
        record_copy['thumbnailUrl'] = f'data:image/jpeg;base64,[BASE64_DATA_{i}]'
        image_records_ref.append(record_copy)
    
    with open(os.path.join(bin_dir, 'image_records.bin.json'), 'w', encoding='utf-8') as f:
        json.dump(image_records_ref, f, ensure_ascii=False, indent=2)
    print(f"  ✅ image_records.bin.json")
    
    # Analyses
    with open(os.path.join(bin_dir, 'analyses.bin.json'), 'w', encoding='utf-8') as f:
        json.dump(analyses, f, ensure_ascii=False, indent=2)
    print(f"  ✅ analyses.bin.json")
    
    print("\n✅ Dados de demonstração gerados com sucesso!")
    print(f"\n📊 Resumo:")
    print(f"  - Projetos: {len(projects)}")
    print(f"  - Imagens: {len(image_records)}")
    print(f"  - Análises: {len(analyses)}")
    print(f"  - Tamanho total: {file_size_mb:.2f} MB")

if __name__ == '__main__':
    os.chdir('/home/ubuntu/demo_metro_sp')
    generate_demo_data()
