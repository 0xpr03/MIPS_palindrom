.data
	# Test String
	str:    .asciiz "O +Genie, der# Herr ehre Dein 3Ego!-"
	tPalindrom: .asciiz "Palindrom"
	tNPalindrom:  .asciiz "Kein "

.text
	main:
		la $s0, str # lade Adresse von str in $s0
		add $v0, $0, $0 # setze $v0 auf 0
	finde_ende: # setzt $s0 auf Endadresse
		lb $s1, 0($s0) # lade erstes byte von str in $s1
		beq $s1, $0, e_finde_ende # $s1 == \0 -> e_finde_ende
		addi $s0, $s0, 1 # $s0 += 1, inc. pointer in str
		j finde_ende # while jump
	e_finde_ende: # setzt $s1 auf Anfangsadresse
		subi $s0, $s0, 1 # $s0 -= 1
		la $s1, str # lade adresse von str in $s1 
		lb $s5, ($s1) # $s5 = str[$s1]
		lb $s6, ($s0) # $s6 = str[$s0]
		jal erzwinge_grossschreibung # ziehe 30 ab wenn nötig
	testschleife:
		jal endetest # pointer überlaufen sich ? -> ende
		jal sonderzeichentest # testet auf sonderzeichen und verändert pointer entsprechend
		jal vergleich # vergleicht $s5 $s6, bricht ab bei differenz
		
		jal lPointer_inkr # linker Pointer inkr.
		jal rPointer_dekr # rechter Pointer dekr.
		j testschleife # while jump
     
    # Unterfunktionen
	endetest: # testet, ob programm fertig ist, da pointer sich "überlaufen"
		sub $t0, $s0, $s1 # $t0 = $s0 - $s1
		blez $t0, p_ende_ja # $t0 <= 0 -> abbruch
		jr $ra
	lPointer_inkr: # inkrementiert linken pointer
		# ra sichern
		subi $sp, $sp, 4
		sw $ra, 4($sp)
		
		addi $s1, $s1, 1 # $s1 += 1
		jal endetest # teste ob pointer "überlaufen"
		lb $s5, ($s1) # $s5 = str[$s1]
		jal erzwinge_grossschreibung # erzwinge grossschreibung
		
		# ra wierderherstellen
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		
		jr $ra
	rPointer_dekr: # dekrementiert rechten pointer
		# ra sichern
		subi $sp, $sp, 4
		sw $ra, 4($sp)
		
		subi $s0, $s0, 1 # $s0 -= 1
		jal endetest # teste ob pointer "überlaufen"
		lb $s6, ($s0) # $s6 = str[$s0]
		jal erzwinge_grossschreibung # erzwinge grossschreibung
		
		# ra wierderherstellen
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		
		jr $ra
	erzwinge_grossschreibung: # zieht von $s5 & $s6 30 ab, falls nötig um kleinschreibung zu gewährleisten
		# ra sichern
		subi $sp, $sp, 4
		sw $ra, 4($sp)
		
		sub $t2, $s5, 91 # $t2 = $s5 - 91
		bgezal $t2, s5_abziehen # $t2 >= 0 -> s5_abziehen
		sub $t2, $s6, 91 # $t2 = $s6 - 91
		bgezal $t2, s6_abziehen # $t2 >= 0 -> s6_abziehen
		
		# ra wierderherstellen
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		
		jr $ra
	s5_abziehen: # ziehe 32 von $s5 ab, x_i -> X_i, x_i in [a-z], X_i in [A-Z]
		sub $s5, $s5, 32
		jr $ra
	s6_abziehen: # ziehe 32 von $s6 ab, x_i -> X_i, x_i in [a-z], X_i in [A-Z]
		sub $s6, $s6, 32
		jr $ra
	sonderzeichentest: # testet rekursiv auf sonderzeichen und verändert pointer falls notwendig
		# ra sichern
		subi $sp, $sp, 4
		sw $ra, 4($sp)
		
		# test linke seite
		subi $t3, $s5, 65 # $t3 = $s5 - 65, 'A'
		bgez $t3, groesser_unterende1 # $t3 >= 0 -> groesser_unterende1, $t3 >= 'A'
		jal lPointer_inkr # inkr linken pointer, da sonderzeichen
		jal sonderzeichentest # rekursiver aufruf, test neuer pointer
		groesser_unterende1:
        
		subi $t3, $s5, 90 # $t3 = $s5 - 90, 'Z'
		bltz $t3, kleiner_oberende1 # $t3 < 0 -> kleiner_oberende1, $t3 <= 'Z'
		jal lPointer_inkr # inkr linken pointer, da sonderzeichen
		jal sonderzeichentest # rekursiver aufruf, test neuer pointer
		kleiner_oberende1:
        
		# test rechte seite
		subi $t3, $s6, 65 # $t3 = $s5 - 65, 'A'
		bgez $t3, groesser_unterende2 # $t3 >= 0 -> groesser_unterende2, $t3 >= 'A'
		jal rPointer_dekr # dekr rechten pointer, da sonderzeichen
		jal sonderzeichentest # rekursiver aufruf, test neuer pointer
		groesser_unterende2:
        
		subi $t3, $s6, 90 # $t3 = $s5 - 90, 'Z'
		bltz $t3, kleiner_oberende2 # $t3 < 0 -> kleiner_oberende2, $t3 <= 'Z'
		jal rPointer_dekr # dekr rechten pointer, da sonderzeichen
		jal sonderzeichentest # rekursiver aufruf, test neuer pointer
		kleiner_oberende2:
        
		jal endetest # test ob pointer sich "überlaufen" -> ende
        
		# ra wierderherstellen
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		
		jr $ra
	vergleich: # vergleicht ob $s5 == $s6, bricht andernfalls ab
		sub $t8, $s5, $s6 # $t8 = $s5 - $s6
		bnez $t8, p_ende_nein # $t8 != 0 -> p_ende_nein
		jr $ra
    
    # Ende-Print funktionen
	p_ende_nein: # print tNPalindrom, durchlauf zu p_ende_ja
		li $v0, 4
		la $a0, tNPalindrom
		syscall
	p_ende_ja: # print tPalindrom
		li $v0, 4
		la $a0, tPalindrom
		syscall
