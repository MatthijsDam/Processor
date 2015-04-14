import Text.Printf
import System.IO
import System.Environment
import System.Process
import System.Exit
import System.Directory
import Data.Time
import Data.List

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
	let runMars dumptype outputfile = rawSystem "java" ["-jar",mars, "a", "ae1",  "mc","CompactTextAtZero",  "dump", ".text", dumptype, outputfile, inputfile]
	runMars "BinaryText" outputfile
	runMars "SegmentWindow" (outputfile ++ "2")

memsize = 255
header = printf "LIBRARY ieee;\nUSE ieee.std_logic_1164.ALL;\nUSE ieee.numeric_std.ALL;\nPACKAGE program IS\n\tCONSTANT low_address\t: INTEGER := 0; \n\tCONSTANT high_address\t: INTEGER := %d;\n\n\tTYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);\n\tCONSTANT program : mem_array := (\n" memsize
footer = "\nOTHERS => \"00000000000000000000000000000000\");\n\nEND;\n"
translateMars2VHDL str = header ++ (unlines $ map (printf "\"%s\",") (lines str)) ++ footer


main = do
	args <- getArgs
	let
		[file] = args
		outfiles = ["../Algorithmic compare/program.vhd", "../Task3/program.vhd"]
		tempfile = file ++ ".mars-out"
		tempfile2 = file ++ ".mars-out2"
	checkFile file
	mapM_ checkFile outfiles
	resMars <- assemble file tempfile
	time <- getZonedTime
	case resMars of
		ExitFailure _ -> exitFailure
		ExitSuccess -> do
			prg <- readFile tempfile
			source <- readFile tempfile2
			let progsize = length (lines prg)
			    line = replicate 40 '!' ++ "\n"
			if progsize > memsize then printfProgress (line++"WARNING: program to big for memory\n"++line) else return ()
			let output = (printf "-- assembled from %s on %s\n\n" file (show time)) ++ comment source ++ translateMars2VHDL prg
			mapM_ (printfProgressLn "writing to %s") outfiles
			mapM_ (\f -> writeFile f output) outfiles
			printfProgressLn "removing %s" tempfile
			removeFile tempfile
			removeFile tempfile2
			return ()

comment str = unlines (map ("-- " ++) (lines str))

checkFile f = do
	exists <- doesFileExist f
	if not exists then do
		printfProgressLn "ERROR: %s not found" f
		exitFailure
	else return ()

printfProgress str = hPrintf stderr str
printfProgressLn str = printfProgress (str++"\n")

