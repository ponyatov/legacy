parser grammar JavaParser;

options {
	tokenVocab = JavaLexer;
}

syntax : (CHAR)* EOF ;
