package ponyatov.legacy;

import src.main.antlr4.JavaParserBaseListener;

class Listener extends JavaParserBaseListener {}

public class App {
    public static void main(String[] args) {
        for (int i = 0; i < args.length; i++) {
            System.out.println("args[" + i + "] = <" + args[i] + "]");
        }
    }
}
