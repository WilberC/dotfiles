# PlantUML Usage

Install or update the isolated PlantUML CLI setup:

```bash
bash scripts/install-plantuml.sh
```

Skip dependency installation when Java and Graphviz are already available:

```bash
bash scripts/install-plantuml.sh --skip-deps
```

Generate a PNG from a diagram:

```bash
plantuml diagram.puml
```

Generate an SVG:

```bash
plantuml -tsvg diagram.puml
```

Generate images for every `.puml` file in a directory:

```bash
plantuml docs/*.puml
```

Check the installed PlantUML version:

```bash
plantuml -version
```

The wrapper uses:

```text
~/.local/share/plantuml/plantuml.jar
```

Override the jar path for one command:

```bash
PLANTUML_JAR=/path/to/plantuml.jar plantuml diagram.puml
```
