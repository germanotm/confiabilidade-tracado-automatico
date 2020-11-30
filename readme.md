# Análise de confiabilidade do traçado cefalométrico automático

Esse repositório contém os arquivos utilizados para criação do artigo que avalia o resultado obtido pela inteligência artificial de localização de pontos cefalométricos implementada pelo [Cfaz.net](https://www.cfaz.net).

## Lista de arquivos

- **Análise de confiabilidade do traçado cefalométrico automático.pdf** - Versão final do artigo em pdf.
- **.python-version** - Versão do python utilizada.
- **compatativo.ipynb** - Notebook jupyter com código fonte.
- **dados_especialista.csv** - Lista de pontos cefalométricos marcados por cada especialista e pela inteligência artificial. 
- **dados_especialista.rb** - Script para extrair os dados do Cfaz.net.
- **figuras** - Imagens utilizadas no artigo.
- **requirements.txt** - Lista de dependências para rodar o código.

## Como rodar

Antes de começar a usar crie o ambiente virtual python. Use o [pyenv](https://github.com/pyenv/pyenv-installer) para instalar a versão do python correta. 

Depois crie o ambiente virtual com o comando:

```shell
python -m venv venv
source venv/bin/activate
```

Feito isso instale as dependências necessárias:
```
pip install -r requirements.txt
```

Para rodar o projeto inicie o jupyter e abre a porta indicada no browser:
```
jupyter notebook
```