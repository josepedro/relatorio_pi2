# É só escrever o comando "make". Entro com "make clean" para limpar a sujeira e
# "make buildclean" para deletar o pdf

all: clean do

do: *.tex
	if test -f *.bib ;\
	then \
		pdflatex sbc-template;\
		echo -n "Buscando citações";\
		grep -v "\%" *.tex > search.temp;\
		if grep '\\cite{'  search.temp -qn;\
		then \
			echo " ";\
			echo -n "Montando bibliografias..." ;\
			pdflatex sbc-template;\
			pdflatex -interaction=batchmode sbc-template;\
			bibtex sbc-template -terse;\
			pdflatex -interaction=batchmode sbc-template;\
			makeglossaries sbc-template;\
			makeindex sbc-template.glo -s main.ist -t main.glg -o main.gls;\
			pdflatex -interaction=batchmode sbc-template;\
			pdflatex -interaction=batchmode sbc-template;\
			echo "Feito.";\
		else \
			pdflatex sbc-template;\
			makeglossaries sbc-template;\
			makeindex sbc-template.glo -s main.ist -t main.glg -o main.gls;\
			pdflatex sbc-template;\
			echo " ... Sem bibliografias";\
		fi;\
	else \
		echo "Arquivo de bibliografias inexistente.";\
		pdflatex sbc-template;\
		pdflatex -interaction=batchmode sbc-template;\
		$(MAKE) clean;\
	fi;
	rm -rf search.temp
	@make clean
	mv sbc-template.pdf $(notdir $(PWD)).pdf
	clear
	pdfinfo $(notdir $(PWD)).pdf -box

# Compila a cada alteração de qualquer arquivo *.tex ou de qualquer *.vhd dentro da pasta 'src'
sbc-template.pdf: *.tex *.bib clean
	clear
#	pdflatex -interaction errorstopmode -interaction=batchmode sbc-template.tex
	pdflatex sbc-template.tex
	clear
	@echo "Compilado pela primeira vez...Feito."
	make bib
	@echo "Compilando pela segunda vez:"
	@pdflatex -interaction=batchmode sbc-template.tex
	@echo -n "Feito\nCompilando pela ultima vez:\n"
	@pdflatex -interaction=batchmode sbc-template.tex
	@echo -n "Limpando sujeira..."
	@make clean
	@echo "Feito."
	
optimize: do
	clear
	cp sbc-template.pdf $(notdir $(PWD)).pdf
	@echo "Informações do arquivo gerado:" $(notdir $(PWD)).pdf
	pdfinfo $(notdir $(PWD)).pdf
	rm -rf sbc-template.pdf
	
# Limpa qualquer sujeira que reste após compilação
# Útil que objetos de linguagens são incluidos e ficam relatando erros após retirados.
clean:
	rm -rf *.aux *.log *.toc *.bbl *.bak *.blg *.out *.lof *.lot *.lol *.glg *.glo *.ist *.xdy *.gls *.acn
	
buildclean:
	rm -rf *.pdf
	
# Por algum motivo o *.pdf sumia da pasta. Gerado apenas para guardar uma copia de segurança na pasta
backup: sbc-template.pdf
	pdfopt sbc-template.pdf $(notdir $(PWD)).pdf

bib: *.bib *.tex
	if test -f *.bib ;\
	then \
		echo -n "Buscando citações";\
		grep -v "\%" *.tex > search.temp;\
		if grep '\\cite{'  search.temp -qn;\
		then \
			echo " ";\
			echo -n "Montando bibliografias..." ;\
			bibtex sbc-template;\
			echo "Feito.";\
		else \
			echo " ... Nenhuma encontrada";\
		fi;\
	else \
		echo "Arquivo de bibliografias inexistente.";\
	fi;
	rm -rf search.temp

configure:
#	if test -d fts; then echo "hello world!";else echo "Not find!"; fi
	grep -v "\%" *.tex > search.temp
	grep '\\cite{'  search.temp
	rm -rv search.temp
#	grep '^%' *.tex
	
.SILENT:
