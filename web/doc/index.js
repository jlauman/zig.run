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
  await editor.loadExamples();

  const handler = function () {
    const exampleName = getDocumentFragment();
    if (exampleName) {
      editor.loadExample(exampleName);
      editor.closeDropDowns();
    } else {
      editor.openDropDowns();
    }
  };

  const exampleName = getDocumentFragment();
  if (exampleName) handler();

  window.addEventListener('hashchange', handler, false);
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
    this._fileName = null;
    this._sourceFiles = [];
    this._sourceMarks = [];
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
            else if (state == 8 && (ch == ' ' || ch == '\n')) return 'link';
            else if (state == 8 && stream.eol()) return 'link';
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
      readOnly: false,
    });
    cm.on('mousedown', function (instance, event) {
      const target = event.target;
      if (target.classList.contains('cm-link')) {
        const url = target.textContent;
        console.log('clic: url=', url);
        window.open(url, '_blank');
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

  closeDropDowns() {
    const elts = [
      document.getElementById('examples'),
      document.getElementById('welcome'),
    ];
    for (const elt of elts) {
      elt.classList.remove('translate-y-0');
      elt.classList.add('-translate-y-full');
    }
  }

  openDropDowns() {
    const elts = [
      document.getElementById('examples'),
      document.getElementById('welcome'),
    ];
    for (const elt of elts) {
      elt.classList.remove('-translate-y-full');
      elt.classList.add('translate-y-0');
    }
  }

  documentClickListener(event) {
    let target = event.target;
    // console.log("documentClickListener: target=", target);
    // the click handler is on the document so the svg "use" element
    // may be the target of a button click.
    if (target.tagName.toLowerCase() === 'use') {
      target = target.parentElement;
    }

    if (target.classList.contains('tab')) {
      const fileName = target.dataset.file_name;
      this.setTab(fileName);
      return;
    }

    if (target.id == 'run_main_button') {
      this.command('run');
      return;
    }

    if (target.id === 'test_file_button') {
      this.command('test');
      return;
    }

    if (target.id === 'format_file_button') {
      this.command('format');
      return;
    }

    if (target.id === 'examples_menu_button') {
      this.closeDropDowns();
      return;
    }

    if (target.id === 'editor_menu_button') {
      const elt = document.getElementById('examples');
      elt.classList.add('translate-y-0');
      elt.classList.remove('-translate-y-full');
      return;
    }

    if (target.id === 'welcome_button') {
      this.openDropDowns();
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
    let response = await fetch('/bin/file.cgi', {
      headers: { 'Content-Type': 'application/json' },
    });
    const json = await response.json();
    this.examples = json.examples;
    // console.log("loadExamples: examples=", this.examples);
    this.constructExamplesList();
  }

  async loadExample(name) {
    console.log('Editor.loadExample: name=', name);
    let example = this.examples.find((e) => e.name == name);
    console.log('loadExample: example=', example);
    if (!example) {
      document.getElementById(
        'editor_name'
      ).textContent = `NO EXAMPLE WITH NAME ${name}`;
      return;
    }
    this._fileName = null;
    this._sourceFiles.splice(0, this._sourceFiles.length); // clear _sourceFiles
    // request file archive from server
    let response = await fetch(`/bin/file.cgi?name=${example.name}`, {
      headers: { 'Content-Type': 'text/plain' },
    });
    let text = await response.text();
    const parts = text.split('//@file_name=').map((s) => s.trim());
    for (let part of parts) {
      if (part.length == 0) continue;
      let i = part.indexOf('\n');
      let name = part.substring(0, i);
      let code = part.substring(i).trim();
      let docs = '';
      this._sourceFiles.push({ name, code, docs });
    }
    // ensure main.zig is first source file
    this._sourceFiles.sort((a, b) => {
      if (a.name === 'main.zig') return -1;
      if (b.name === 'main.zig') return 1;
      return a.name < b.name;
    });
    // console.log(this._sourceFiles);
    // set example title
    document.getElementById('editor_name').textContent = example.title;
    this.loadExampleSourceDocs();
    this.loadExampleTabs();
  }

  loadExampleSourceDocs() {
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
    let response = await fetch('/bin/play.cgi', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        command: command,
        file_name: command === 'run' ? 'main.zig' : this.getSelectedFileName(),
        source: files.join('\n'),
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
        this._outputCodeMirror.setValue(json.stdout + '\n--- 2&>1 ---\n' + json.stderr);
      }
    } else {
      let text = await response.text();
      console.log(text);
      this._outputCodeMirror.setValue(
        `statusText=${response.statusText}${text}`
      );
    }
  }
}

main().catch((err) => console.error(err));
