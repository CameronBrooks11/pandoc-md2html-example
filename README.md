# pandoc Markdown to HTML Example

This small project shows a possible workflow for converting [Markdown files](https://docs.github.com/de/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) (`.md`) to HTML files (`.html`) using pandoc ([docs](https://pandoc.org/MANUAL.html), [installation](https://pandoc.org/installing.html)).

The main goal of this project is to show some commonly used options when running pandoc and give an example of how creating a multi-page website with pandoc could work.

- `convert.sh`: Shows the arguments that are used with pandoc, how parameters are passed to pandoc and how creating the website can be automated.
- `styling.css`: A normal css file.
- `template.html`: The template file that is mostly `.html` but includes pandoc control elements (denoted by `$`) which will be replaced during conversion.
- `source/index.md`: A simple example page, showing how the body of a markdown file is translated by pandoc and how a header section can be used to add meta information.

Write the page layout once in html and css and then convert multiple `.md` files to `.html`.

## Examples in the Wild

- The original author of this repo built their website [montebaur.tech](https://montebaur.tech/projects/mtb_tech_info.html) with this original approach.

## Dependencies

- `pandoc`, need version >=2.13 to process citations
- `entr` (optional), used for automatic conversion triggering during development
- `python3`

## Scripts

### Makefile Commands

You can now use `make` instead of calling scripts directly (requires Bash & GNU Make).

- **`make build`**  
  Build the site (runs `convert.sh`).
- **`make clean`**  
  Delete the generated `_website/` directory.
- **`make watch`**  
  Rebuild on changes (requires [`entr`](https://eradman.com/entrproject/)).
- **`make serve`**  
  Start a quick HTTP server at `http://localhost:8000` for preview.

> **Windows users**: run these commands inside **Git Bash** or **WSL**, where Bash and Make are available. You may need to install GNU Make via Chocolatey (choco install make in an elevated PowerShell) and then re-open your shell.

### Building the website

`convert.sh`: Builds the website, i.e. converts from Markdown to HTML. Takes as an input a list of markdown files and creates a folder `website/` for the converted files. It will also copy all of the media data and styling info to this folder. `website/` is essentially the root of the website.

```bash
./convert.sh
```

If this command ran successfully, there should be a new file called `_website/index.html` which you can open in your browser.

### Automated updates during local development

`autoupdate.sh`: Watches changes in the markdown files and updates the website after a change occurs. This file is used for development and will update the website once a file was updated. Using the commands from the script to only watch a single file is recommended to safe time.

```bash
# Website will automatcially be regenerated if one of those files changes:
./autoupdate.sh source/projects/page1.md source/page_index.md
```

## Attribution

This project is a further development of the approach in [montioo/pandoc-md2html-example](https://github.com/montioo/pandoc-md2html-example) and builds upon it.
