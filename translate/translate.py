import deepl
import errno
import os
import pkgutil
import re
import requests
import subprocess
import yaml

from translate import __app_name__, __version__

# "gfm+definition_lists+fenced_divs+pipe_tables-fenced_code_attributes",
md_extensions_to = 'markdown+definition_lists+fenced_divs+backtick_code_blocks+fenced_code_attributes+pipe_tables-simple_tables'

# "gfm+definition_lists+fenced_divs+pipe_tables",
md_extensions_from = 'markdown+definition_lists+fenced_divs+backtick_code_blocks+fenced_code_attributes+pipe_tables'

def load_auth() -> str:
    """
    Look up DEEPL_AUTH environmental variable for authentication.
    """
    AUTH = os.getenv('DEEPL_AUTH')
    if not AUTH:
       raise ValueError('Environmental variable DEEPL_AUTH required for translate with Deepl REST API')

    return AUTH

def load_config() -> dict:
    """
    Load config.yml application configuration.
    """
    raw = pkgutil.get_data('translate', "config.yml")
    config = yaml.safe_load(raw.decode('utf-8'))

    return config


def convert_markdown(md_file: str) -> str:
    """
    Use pandoc to convert markdown file to html file for translation.
    :param md_file: Markdown file path
    :return: html file path
    """
    if not os.path.exists(md_file):
       raise FileNotFoundError(errno.ENOENT, f"Markdown file does not exist at location:", md_file)

    config = load_config()
    if not md_file[-3:] == '.md':
       raise FileNotFoundError(errno.ENOENT, f"Markdown 'md' extension required:", md_file)

    upload_folder = config['upload_folder']

    path = re.sub("^docs/",upload_folder+'/', md_file)
    path = path.replace(".en.md",".en.html")
    path = path.replace(".md",".html")
    html_file = path

    html_dir = os.path.dirname(path)
    if not os.path.exists(html_dir):
       print("Translation directory:",html_dir)
       os.makedirs(html_dir)

    md_prep = re.sub(r"\.html",r".prep.md", path)

    print("Preprocessing ",md_file," to ",md_prep)
    preprocess_markdown(md_file,md_prep)

    print("Converting ",md_prep," to ",html_file)
    # pandoc --from gfm --to html -o index.en.html index.md
    completed = subprocess.run(["pandoc",
       "--from", md_extensions_from,
       "--to","html",
       "--wrap=none",
       "--eol=lf",
       "-o", html_file,
       md_prep
    ])
    if completed.returncode != 0:
        print(completed)

    if not os.path.exists(html_file):
       raise FileNotFoundError(errno.ENOENT, f"Pandoc did not create html file:", html_file)

    return html_file

def preprocess_markdown(md_file:str, md_prep: str) -> str:
    with open(md_file, 'r') as file:
        text = file.read()

    clean = ''
    code = ''
    admonition = None

    # handle notes as pandoc fenced_divs
    for line in text.splitlines():
        # phase 1: code-block pre-processing
        #
        # cause pandoc #markdown or #text to force to fenced codeblocks (rather than indent)
        if re.match("^```", line):
          if len(code) > 0:
            # print("code-end: '"+line+"'")
            # end code block (so no processing)
            code = ''

          else:
            # print("code-block: '" + line +"'")
            line = re.sub(
                 r"^```(\S+)$",
                 r"```#\1",
                 line,
                 flags=re.MULTILINE
            )
            line = re.sub(
                 r"^```$",
                 r"```#text",
                 line,
                 flags=re.MULTILINE
            )
            code = line[4:]

        # phase 2: process blocks
        if not admonition:
           if '!!! ' in line:
               # print('admonition start  : "'+line+'"')
               admonition = line
           else:
               clean += line + '\n'
        else:
           indent = admonition.index('!!! ')
           padding = admonition[0:indent]

           if len(line) == 0:
               if '\n' in admonition:
                   # print('admonition blank  : "'+line+'"')
                   admonition += line+"\n"
               else:
                   # print('admonition skip   : "'+line+'"')
                   admonition += "\n"
           elif line[0:indent].isspace():
               # print('admonition content: "'+line+'"')
               # use indent level to gather admonition contents
               admonition += padding+line[indent+4:]+'\n'
           else:
               # print('admonition end    : "'+line+'"')
               # outdent admonition completed
               first_newline = admonition.index('\n')
               last_newline = admonition.rindex('\n')

               title = admonition[indent+4:first_newline]
               contents = admonition[first_newline:last_newline]

               # output as pandoc fenced_divs
               clean += padding+"::: "+title
               clean += contents
               clean += padding+":::\n\n"

               # remember to output line that breaks indent level
               admonition = None

               clean += line + '\n'

    with open(md_prep,'w') as markdown:
        markdown.write(clean)

def convert_html(html_file: str) -> str:
    """
    Use pandoc to convert markdown file to html file for translation.
    :param html_file: HTML file path
    :return: md file path
    """
    if not os.path.exists(html_file):
       raise FileNotFoundError(errno.ENOENT, f"HTML file does not exist at location:", html_file)

    if not html_file[-5:] == '.html':
       raise FileNotFoundError(errno.ENOENT, f"HTML '.html' extension required:", html_file)

    # prep html file for conversion
    html_tmp_file = html_file[0:-5] + '.tmp.html'

    preprocess_html(html_file, html_tmp_file)
    if not os.path.exists(html_tmp_file):
       raise FileNotFoundError(errno.ENOENT, f"Did not create preprocessed html file:", html_tmp_file)

    if html_file[:-8] == '.fr.html':
       md_file = html_file[0:-8] + '.fr.md'
    if html_file[:-5] == '.html':
       md_file = html_file[0:-8] + '.md'
    else:
       md_file = html_file[0:-5] + '.md'

    md_tmp_file = md_file[0:-3]+".tmp.md"

    completed = subprocess.run(["pandoc",
       "--from","html",
       "--to", md_extensions_to,
       "--wrap=none",
       "--eol=lf",
       "-o", md_tmp_file,
       html_tmp_file
    ])
    print(completed)

    if not os.path.exists(md_tmp_file):
       raise FileNotFoundError(errno.ENOENT, f"Pandoc did not create temporary md file:", tmp_file)

    postprocess_markdown(md_tmp_file, md_file)
    if not os.path.exists(md_file):
       raise FileNotFoundError(errno.ENOENT, f"Did not create postprocessed md file:", md_file)

    return md_file

def preprocess_html(html_file: str, html_clean: str):
    with open(html_file, 'r') as html:
        data = html.read()

    # Fix image captions
    #
    #     ![Search field](img/search.png) *Champ de recherche*
    #
    # Clean:
    #
    #    ![Search field](img/search.png)
    #    *Champ de recherche*
    #
    clean = re.sub(
        r'^<p>:: : note ',
        r'<div class="note">\n<p>',
        data,
        flags=re.MULTILINE
    )
    clean = re.sub(
        r'^<p>:: :</p>',
        r'</div>',
        clean,
        flags=re.MULTILINE
    )
    with open(html_clean,'w') as html:
        html.write(clean)

def postprocess_markdown(md_file: str, md_clean: str):
    with open(md_file, 'r') as markdown:
        data = markdown.read()

    # Fix image captions
    #
    #     ![Search field](img/search.png) *Champ de recherche*
    #
    # Clean:
    #
    #    ![Search field](img/search.png)
    #    *Champ de recherche*
    #
#     data = re.sub(
#         r"^(\s*)\!\[(.*)\]\((.*)\)\s\*(.*)\*$",
#         r"\1![\2](\3)\1*\4*",
#         data,
#         flags=re.MULTILINE
#     )
    # fix icons
    data = re.sub(
        r":(fontawesome-\S*)\s:",
        r":\1:",
        data,
        flags=re.MULTILINE
    )
    # fix fence text blocks
    data = re.sub(
        r'^``` #text$',
        r'```',
        data,
        flags=re.MULTILINE
    )
    # fix fenced code blocks
    data = re.sub(
        r'^``` #(.+)$',
        r'```\1',
        data,
        flags=re.MULTILINE
    )
    with open(md_clean,'w') as markdown:
        markdown.write(data)

def deepl_document(en_html:str, fr_html:str):
    """
    Submit english html file to deepl for translation.
    :param en_html: English html file
    :param fr_html: French html file
    :return: status
    """

    if not os.path.exists(en_html):
       raise FileNotFoundError(errno.ENOENT, f"HTML file does not exist at location:", en_html)

    config = load_config()
    AUTH = load_auth()

    translator = deepl.Translator(AUTH)

    try:
        # Using translate_document_from_filepath() with file paths
        translator.translate_document_from_filepath(
            en_html,
            fr_html,
            source_lang='EN',
            target_lang="FR",
            formality="more"
        )

    except deepl.DocumentTranslationException as error:
        # If an error occurs during document translation after the document was
        # already uploaded, a DocumentTranslationException is raised. The
        # document_handle property contains the document handle that may be used to
        # later retrieve the document from the server, or contact DeepL support.
        doc_id = error.document_handle.id
        doc_key = error.document_handle.key
        print(f"Error after uploading ${error}, id: ${doc_id} key: ${doc_key}")

    except deepl.DeepLException as error:
        # Errors during upload raise a DeepLException
        print(error)

    if not os.path.exists(fr_html):
       raise FileNotFoundError(errno.ENOENT, f"Deepl did not create md file:", fr_html)

    return

# def deepl_translate(html_file: str) -> dict:
#     """
#     Submit html_file to deepl for translation.
#     :param html_file: HTML file path
#     :return: json response from deepl api
#     """
#     if not os.path.exists(html_file):
#        raise FileNotFoundError(errno.ENOENT, f"HTML file does not exist at location:", html_file)
#
#     config = load_config()
#     AUTH = load_auth()
#
#     translator = deepl.Translator(AUTH)
#
#     response = requests.post(
#        config['deepl_base_url']+'/v2/document',
#        data={
#           'source_lang':'EN',
#           'target_lang':'FR',
#           'tag_handling':'xml',
#           'formality':'prefer_more',
#           'ignore_tags':'code',
#        },
#        files={
#           'file': open(html_file,'rt')
#        },
#        headers={
#           'Authorization': f"DeepL-Auth-Key {AUTH}"}
#     )
#     status = response.json()
#     return status
#
# def deepl_status(document_id: str, document_key: str) -> dict:
#     """
#     Submit document_id to deepl for translation.
#     :param document_id: ID provided from document upload
#     :param document_key: Encryption key provided from document uploaded
#     :return: json status from deepl api
#     """
#     config = load_config()
#     AUTH = load_auth()
#
#     response = requests.post(
#        config['deepl_base_url']+'/v2/document/'+document_id,
#        data={'document_key':document_key,},
#        headers={
#           'Authorization': f"DeepL-Auth-Key {AUTH}",
#           'Content-Type': 'application/json'},
#     )
#     status = response.json()
#     return status


