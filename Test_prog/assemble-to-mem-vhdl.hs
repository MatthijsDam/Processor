import Text.Printf
import System.IO
import System.Environment
import System.Process
import System.Exit
import System.Directory

findMars :: IO String
findMars = do
	let mars = "../../Mars4_5.jar" --TODO find mars.jar automatically
	checkFile mars
	printfProgressLn "found Mars at: %s" mars
	return mars

-- java -jar ../../Mars4_5.jar a ae1 dump .text BinaryText output.txt mult_test.asm
assemble inputfile outputfile = do
	mars <- findMars
	printfProgressLn "running mars to assemble %s to %s" inputfile outputfile
	rawSystem "java" ["-jar",mars, "a", "ae1", "dump", ".text", "BinaryText", outputfile, inputfile]

header = "LIBRARY ieee;\nUSE ieee.std_logic_1164.ALL;\nUSE ieee.numeric_std.ALL;\nPACKAGE program IS\n\tCONSTANT low_address\t: INTEGER := 0; \n\tCONSTANT high_address\t: INTEGER := 255;\n\n\tTYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);\n\tCONSTANT program : mem_array := (\n"
footer = "\nOTHERS => \"00000000000000000000000000000000\");\n\nEND;\n"
translateMars2VHDL str = header ++ (unlines $ map (printf "\"%s\",") (lines str)) ++ footer

main = do
	args <- getArgs
	let
		[file] = args
		outfile = "../Algorithmic compare/program.vhd"
		tempfile = file ++ ".mars-out"
	checkFile file
	checkFile outfile
	resMars <- assemble file tempfile
	case resMars of
		ExitFailure _ -> exitFailure
		ExitSuccess -> do
			str <- readFile tempfile
			let output = (printf "-- assembled from %s\n" file) ++ translateMars2VHDL str
			printfProgressLn "writing to %s" outfile
			writeFile outfile output
			printfProgressLn "removing %s" tempfile
			removeFile tempfile
			return ()

checkFile f = do
	exists <- doesFileExist f
	if not exists then do
		printfProgressLn "ERROR: %s not found" f
		exitFailure
	else return ()

printfProgress str = hPrintf stderr str
printfProgressLn str = printfProgress (str++"\n")

