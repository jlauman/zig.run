window.ZigRun = window.ZigRun || {};

async function main() {
  // prettier-ignore
  try {
    document.getElementById('version_build').textContent = `build=${ZigRun.build}`;
    document.getElementById('version_commit').textContent = `commit=${ZigRun.commit}`;
  } catch (err) {
    console.error(err);
  }

  const editor = new Editor();
  window.ZigRun.editor = editor;
  // example loaded from external source into snippet page does
  // not have the zig page or example list page.
  editor._isApp = document.getElementById('example_list') ? true : false;
  if (editor._isApp) {
    await editor.loadExamples();

    const handler = function () {
      // hack to ensure the browser's scroll is zero-ed
      window.scrollTo(0, 0);
      const exampleName = getDocumentFragment();
      const el = document.getElementById('slide');
      if (exampleName && el.classList.contains('page-1')) {
        editor.loadExample(exampleName);
        const slide = document.getElementById('slide_after_select').checked;
        if (slide) editor.setPage(2);
      } else if (exampleName) {
        editor.loadExample(exampleName);
        editor.setPage(2);
      } else {
        editor.setPage(0);
      }
    };

    const exampleName = getDocumentFragment();
    if (exampleName) handler();

    window.addEventListener('hashchange', handler, false);
  } else {
    // snippet runner...
    editor
      .loadExample(document.location.hash)
      .then((command) => editor.command(command));
  }

  window.scrollTo(0, 0);
}

function getDocumentFragment() {
  let hash = document.location.hash;
  if (hash.startsWith('#')) hash = hash.substring(1);
  if (hash.length == 0) return null;
  return hash;
}

// function parseQuery(string) {
//   const query = new Map();
//   const pairs = (string[0] === '?' ? string.substr(1) : string).split('&');
//   for (const tmp of pairs) {
//     const pair = tmp.split('=');
//     query.set(decodeURIComponent(pair[0]), decodeURIComponent(pair[1] || ''));
//   }
//   return query;
// }

// function getQueryParam(string, name) {
//   let query = parseQuery(string);
//   return query.get(name);
// }

class Editor {
  constructor() {
    this._isApp = true;
    this._fileName = null;
    this._sourceFiles = [];
    this._sourceCodeMirror = this.constructSourceCodeMirror();
    this._outputCodeMirror = this.constructOutputCodeMirror();
    document.addEventListener('click', this.documentClickListener.bind(this));
  }

  constructSourceCodeMirror() {
    const sourceDiv = document.getElementById('source_panel');
    return CodeMirror(sourceDiv, {
      value: '',
      mode: 'zig',
      // theme: "darcula",
      lineNumbers: true,
      autofocus: true,
      indentUnit: 4,
      extraKeys: {
        Tab: function (cm) {
          const spaces = Array(cm.getOption('indentUnit') + 1).join(' ');
          cm.replaceSelection(spaces, 'end', '+input');
        },
        'Ctrl-/': function (cm) {
          cm.execCommand('toggleComment');
        },
      },
    });
  }

  constructOutputCodeMirror() {
    CodeMirror.defineMode('textlink', function (config, parserConfig) {
      var mustacheOverlay = {
        token: function (stream) {
          let state = 0;
          let ch = stream.next();
          while (ch != null) {
            if (state == 0 && ch === 'h') state = 1;
            else if (state == 1 && ch == 't') state = 2;
            else if (state == 2 && ch == 't') state = 3;
            else if (state == 3 && ch == 'p') state = 4;
            else if (state == 4 && ch == 's') state = 5;
            else if (state == 4 && ch == ':') state = 7;
            else if (state == 5 && ch == ':') state = 6;
            else if (state == 6 && ch == '/') state = 7;
            else if (state == 7 && ch == '/') state = 8;
            else if (
              state == 8 &&
              (ch == ' ' || ch == '"' || ch == "'" || ch == '\n')
            ) {
              stream.backUp(1);
              return 'link';
            } else if (state == 8 && stream.eol()) return 'link';
            else if (state == 8) state = state;
            else return null;
            ch = stream.next();
          }
          return null;
        },
      };
      return CodeMirror.overlayMode(
        CodeMirror.getMode(config, parserConfig.backdrop || 'text'),
        mustacheOverlay
      );
    });

    const outputDiv = document.getElementById('output_panel');
    const cm = CodeMirror(outputDiv, {
      value: '',
      mode: 'textlink',
      lineNumbers: false,
      readOnly: true,
    });
    cm.on('mousedown', function (_instance, event) {
      const target = event.target;
      if (target.classList.contains('cm-link')) {
        const url = target.textContent;
        console.log('click: url=', url);
        if (url.startsWith('https://zig.run')) {
          const fragment = url.split('#')[1];
          document.location = `#${fragment}`;
        } else {
          window.open(url, '_blank');
        }
      }
    });
    return cm;
  }

  constructExamplesList() {
    const div = document.getElementById('example_list');
    for (const example of this.examples) {
      // console.log("constructExamplesList: example=", example);
      div.insertAdjacentHTML(
        'beforeend',
        `
        <li class="example_name pl-2" data-example_name="${example.name}">${example.title}</li>
        `
      );
    }
  }

  setPage(number) {
    // snippet runner does not have page slide.
    if (this._isApp) {
      if (number > -1 && number < 3) {
        const el = document.getElementById('slide');
        for (let i = 0; i < 3; i++) el.classList.remove(`page-${i}`);
        el.classList.add(`page-${number}`);
        const slb_el = document.getElementById('slide_left_button');
        const srb_el = document.getElementById('slide_right_button');
        if (number == 0) slb_el.classList.add('hidden');
        else slb_el.classList.remove('hidden');
        if (number == 2) srb_el.classList.add('hidden');
        else srb_el.classList.remove('hidden');
      } else {
        throw new Error(`invalid page number=${number}`);
      }
    }
  }

  documentClickListener(event) {
    let target = event.target;
    // the click handler is on the document so the svg "use" element
    // may be the target of a button click.
    if (target.tagName.toLowerCase() === 'use') {
      target = target.parentElement;
    }
    // console.log('documentClickListener: target=', target);

    if (target.id === 'slide_left_button') {
      const el = document.getElementById('slide');
      if (el.classList.contains('page-2')) {
        this.setPage(1);
      } else if (el.classList.contains('page-1')) {
        this.setPage(0);
      }
      return;
    }

    if (target.id === 'slide_right_button') {
      const el = document.getElementById('slide');
      if (el.classList.contains('page-0')) {
        this.setPage(1);
      } else if (el.classList.contains('page-1')) {
        this.setPage(2);
      }
      return;
    }

    if (target.classList.contains('tab')) {
      const fileName = target.dataset.file_name;
      this.setTab(fileName);
      return;
    }

    if (target.id == 'run_main_button') {
      // ensure that the button is enabled
      if (target.classList.contains('svg-button')) {
        this.setPage(2);
        this.command('run');
      }
      return;
    }

    if (target.id === 'test_file_button') {
      this.setPage(2);
      this.command('test');
      return;
    }

    if (target.id === 'format_file_button') {
      this.command('format');
      return;
    }

    if (target.id === 'create_link_button') {
      this.createLinkButton();
      return;
    }

    if (target.id === 'create_widget_code') {
      this.createWidgetCode();
      return;
    }

    if (target.id === 'examples_menu_button') {
      this.setPage(1);
      return;
    }

    if (target.classList.contains('example_name')) {
      const exampleName = target.dataset.example_name;
      // console.log("click: example_name=", exampleName);
      document.location = `#${exampleName}`;
      return;
    }
  }

  async loadExamples() {
    let response = await fetch('/example', {
      headers: { 'Content-Type': 'application/json' },
    });
    const json = await response.json();
    this.examples = json.examples;
    // console.log("loadExamples: examples=", this.examples);
    this.constructExamplesList();
  }

  async loadExample(name) {
    console.log('Editor.loadExample: name=', name);
    let command = 'run';
    if (name && name.startsWith('#')) {
      // script runner...
      const code = atob(name.substring(1));
      const match = code.match(/^\/\/\! (.*)\n/);
      const title = Array.isArray(match) ? match[1] : 'Snippet';
      name = '900_snippet'; // change argument value
      this.examples = [{ title, name }];
      this._sourceFiles.push({ name: 'main.zig', code, docs: '' });
      command = code.includes('\ntest ') ? 'test' : 'run';
    } else {
      let example = this.examples.find((e) => e.name == name);
      console.log('loadExample: example=', example);
      if (!example) {
        document.getElementById(
          'example_title'
        ).textContent = `NO EXAMPLE WITH NAME ${name}`;
        return;
      }
      this._fileName = null;
      this._sourceFiles.splice(0, this._sourceFiles.length); // clear _sourceFiles
      // get example archive (may be from cache) and parse it
      const text = await this.fetchExampleArchive(example);
      const parts = text.split('//@file_name=').map((s) => s.trim());
      for (let part of parts) {
        if (part.length == 0) continue;
        let i = part.indexOf('\n');
        let name = part.substring(0, i);
        let code = part.substring(i).trim();
        let docs = '';
        this._sourceFiles.push({ name, code, docs });
      }
      // ensure main.zig is first source file, or
      // test.zig is first source file
      this._sourceFiles.sort((a, b) => {
        if (a.name === 'main.zig') return -1;
        if (b.name === 'main.zig') return 1;
        if (a.name === 'test.zig') return -1;
        if (b.name === 'test.zig') return 1;
        return a.name < b.name;
      });
    }
    // if there is not main.zig file diable the play button
    const mainZig = this._sourceFiles.find((a) => a.name === 'main.zig');
    const el = document.getElementById('run_main_button');
    if (mainZig) {
      el.classList.remove('svg-button-disabled');
      el.classList.add('svg-button');
    } else {
      el.classList.remove('svg-button');
      el.classList.add('svg-button-disabled');
    }
    // enable snippet buttons for snippet editor and runner
    if (name === '900_snippet' || !this._isApp) {
      document.getElementById('create_link_button').classList.remove('hidden');
      document.getElementById('create_widget_code').classList.remove('hidden');
    }
    // console.log(this._sourceFiles);
    // set example title
    this.loadExampleSourceDocs(name);
    this.setExampleTitle(name);
    this.loadExampleTabs();
    return command;
  }

  setExampleTitle(name) {
    for (let example of this.examples) {
      if (example.name === name) {
        document.getElementById('example_title').textContent = example.title;
        break;
      }
    }
  }

  loadExampleSourceDocs(name) {
    if (name === '900_snippet') {
      // instruction for using buttons and snippets
    } else {
      for (let file of this._sourceFiles) {
        // console.log("loadExampleSourceDocs: file=", file);
        let code = [];
        let docs = [];
        for (let line of file.code.split('\n')) {
          // console.log('line=', line);
          if (line.startsWith('//!')) {
            docs.push(line.substring(3).trim());
          } else {
            code.push(line);
          }
        }
        file.code = code.join('\n');
        file.docs = docs.join('\n');
      }
    }
  }

  loadExampleTabs() {
    // clear tabs
    document.querySelectorAll('.tab').forEach((el) => el.remove());
    // build tabs
    const tabs = document.getElementById('tabs');
    for (let file of this._sourceFiles) {
      tabs.insertAdjacentHTML(
        'beforeend',
        `
        <div id="${file.name}" class="tab" data-file_name="${file.name}">${file.name}</div>
        `
      );
    }
    // set first file as active tab
    if (this._sourceFiles.length > 0) {
      this.setTab(this._sourceFiles[0].name);
    }
  }

  setTab(name) {
    const newFile = this._sourceFiles.find((file) => file.name === name);
    if (newFile) {
      if (this._fileName != null) {
        const oldFile = this._sourceFiles.find(
          (file) => file.name === this._fileName
        );
        oldFile.code = this._sourceCodeMirror.getValue();
        const div = document.getElementById(this._fileName);
        div.classList.remove('tab-active');
      }
      this._fileName = newFile.name;
      this._sourceCodeMirror.setValue(newFile.code);
      this._sourceCodeMirror.refresh();
      if (newFile.docs !== '') {
        this._outputCodeMirror.setValue(newFile.docs);
        this._outputCodeMirror.refresh();
      }
      const div = document.getElementById(this._fileName);
      div.classList.add('tab-active');
    }
  }

  getSelectedFileName() {
    const file = this._sourceFiles.find((file) => file.name === this._fileName);
    if (file) return file.name;
    throw new Error('no selected file');
  }

  setSelectedFileSource(source) {
    const file = this._sourceFiles.find((file) => file.name === this._fileName);
    if (!file) throw new Error('no file is selected');
    file.code = source;
    this._sourceCodeMirror.setValue(file.code);
    // this._sourceCodeMirror.refresh();
  }

  spinner(active) {
    const el1 = document.getElementById('run_status_circle');
    const el2 = document.getElementById('run_status_play');
    if (active) {
      el1.classList.remove('stop_color');
      el1.classList.add('exec_color');
      el2.classList.remove('hidden');
    } else {
      el1.classList.remove('exec_color');
      el1.classList.add('stop_color');
      el2.classList.add('hidden');
    }
  }

  async fetchExampleArchive(example) {
    // console.log('fetchExampleArchive: example=', example);
    let archive = '';
    if (example.archive) {
      archive = example.archive;
    } else {
      let response = await fetch(`/example/${example.name}`, {
        headers: { 'Content-Type': 'text/plain' },
      });
      archive = await response.text();
      example.archive = archive;
    }
    return archive;
  }

  async command(command) {
    this._outputCodeMirror.setValue('');
    if (this._fileName != null) {
      const file = this._sourceFiles.find(
        (file) => file.name === this._fileName
      );
      file.code = this._sourceCodeMirror.getValue();
    }
    let files = [];
    for (let file of this._sourceFiles) {
      files.push(`//@file_name=${file.name}`);
      files.push(file.code);
    }
    const argv = document.getElementById('argv').value.trim();
    try {
      this.spinner(true);
      // pathname is for the /test route+container
      let response = await fetch(`/play`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          command: command,
          file_name:
            command === 'run' ? 'main.zig' : this.getSelectedFileName(),
          source: files.join('\n'),
          argv: argv,
          stderr: '', // play.cgi uses same struct for request and response
          stdout: '', // so stderr and stdout are required request properties.
        }),
      });
      if (response.status === 200) {
        let json = await response.json();
        // console.log(json);
        if (command === 'format') {
          this.setSelectedFileSource(json.source);
        } else {
          // command === run || command === test
          this._outputCodeMirror.setValue(
            json.stdout + '\n--- 2&>1 ---\n' + json.stderr
          );
        }
      } else {
        // let text = await response.text();
        let status = `ERROR: ${response.status} (${response.statusText})`;
        console.error(status);
        this._outputCodeMirror.setValue(status);
      }
    } finally {
      this.spinner(false);
    }
  }

  createLinkButton() {
    const code = this._sourceCodeMirror.getValue();
    const match = code.match(/^\/\/\! (.*)\n/);
    const title = Array.isArray(match) ? match[1] : 'Snippet';
    // prettier-ignore
    const value = `<a target="_blank" href="${location.origin}/snippet/#${btoa(code)}"><button>Run ${title}</button></a>\n`;
    this._outputCodeMirror.setValue(value);
  }

  createWidgetCode() {
    const code = this._sourceCodeMirror.getValue();
    const match = code.match(/^\/\/\! (.*)\n/);
    const title = Array.isArray(match) ? match[1] : 'Snippet';
    // prettier-ignore
    const value = `
<div class="zig-example">
    <pre><button>RUN</button>&nbsp;<button>RESET</button>&nbsp;<button>EDIT</button><br/><br/><code class="language-zig"></code>
    <script>
        let playUrl = '${location.origin}/play/base64/${btoa(code)}';
        let editUrl = '${location.origin}/snippet/#${btoa(code)}';
        let children = Array.from(document.currentScript.parentElement.children); 
        let code = children.find((e) => e.tagName == 'CODE');
        let button = (label) => children.find((e) => e.tagName == 'BUTTON' && e.textContent == label); 
        let output = (t) => new Promise((resolve) => { code.textContent = t; resolve(); });
        button('RUN').onclick = () => output('Running...').then(fetch(playUrl).then(r => r.json()).then(t => output(t.stdout + '\\n----------\\n' + t.stderr)));
        button('RESET').onclick = () => output(atob(editUrl.split('#')[1])).then(() => Prism && Prism.highlightElement(code));
        button('EDIT').onclick = () => window.open(editUrl);
        output(atob(editUrl.split('#')[1])).then(() => Prism && Prism.highlightElement(code));
    </script>
    </pre>
</div>
    `.trim();
    this._outputCodeMirror.setValue(value);
  }
} // end Editor

main().catch((err) => console.error(err));
