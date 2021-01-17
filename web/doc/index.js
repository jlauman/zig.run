window.ZigRun = window.ZigRun || {};

class Editor {
  constructor() {
    this._fileId = null;
    this._sourceFiles = [];
    this._sourceMarks = [];
    this._sourceCodeMirror = this.constructSourceCodeMirror();
    this._outputCodeMirror = this.constructOutputCodeMirror();
    // this.constructTableOfContents();
    // this.addListeners();
  }

  constructSourceCodeMirror() {
    const sourceDiv = document.getElementById('source_panel');
    return CodeMirror(sourceDiv, {
      value: '',
      mode: 'javascript',
      lineNumbers: true,
      autofocus: true,
      extraKeys: {
        Tab: function (cm) {
          const spaces = Array(cm.getOption('indentUnit') + 3).join(' ');
          cm.replaceSelection(spaces, 'end', '+input');
        },
      },
    });
  }

  constructOutputCodeMirror() {
    const outputDiv = document.getElementById('output_panel');
    return CodeMirror(outputDiv, {
      value: '',
      mode: 'text',
      lineNumbers: false,
      readOnly: true,
    });
  }

  constructTableOfContents() {
    const div = document.getElementById('toc_list');
    for (const page of ZigRun.toc) {
      console.log('constructTableOfContents: page=', page);
      div.insertAdjacentHTML(
        'beforeend',
        `
        <li class="toc_item pl-2">${page.file}</li>
        `
      );
    }
  }

  addListeners() {
    {
      const wm_button = document.getElementById('welcome_menu_button');
      wm_button.addEventListener('click', () => {
        const elt = document.getElementById('welcome');
        elt.classList.add('hidden');
      });

      const em_button = document.getElementById('editor_menu_button');
      em_button.addEventListener('click', () => {
        const elt = document.getElementById('welcome');
        elt.classList.remove('hidden');
      });

      const divs = document.querySelectorAll('.toc_item');
      divs.forEach((el) =>
        el.addEventListener('click', (event) => {
          const file = event.target.textContent;
          console.log('click file=', file);
          const elt = document.getElementById('welcome');
          elt.classList.add('hidden');
          const prefix = file.split('_')[0];
          this.load(prefix);
        })
      );

      const rm_button = document.getElementById('run_main_button');
      rm_button.addEventListener('click', this.command.bind(this, 'run'));

      const tf_button = document.getElementById('test_file_button');
      tf_button.addEventListener('click', this.command.bind(this, 'test'));

      const ff_button = document.getElementById('format_file_button');
      ff_button.addEventListener('click', this.command.bind(this, 'fmt'));

      // const next_doc_button = document.getElementById('next_doc_button');
      // next_doc_button.addEventListener('click', () => {
      //   let nextKey = null;
      //   let nextText = null;
      //   const activeArray = document.querySelectorAll('.doc-button-active');
      //   if (activeArray.length == 0) {
      //     nextKey = Object.keys(this._sourceDocs)[0];
      //     nextText = this._sourceDocs[nextKey];
      //   } else {
      //     let activeButton = activeArray[0];
      //     const activeKey = activeButton.id.substring('doc_button_'.length);
      //     for (let key of Object.keys(this._sourceDocs)) {
      //       if (nextKey) {
      //         nextKey = key;
      //         nextText = this._sourceDocs[key];
      //         break;
      //       } else if (key === activeKey) nextKey = true;
      //     }
      //   }
      //   if (nextKey && nextText) {
      //     document
      //       .querySelectorAll('.doc-button')
      //       .forEach((b) => b.classList.remove('doc-button-active'));
      //     const button = document.getElementById('doc_button_' + nextKey);
      //     button.classList.add('doc-button-active');
      //     const line = parseInt(nextKey) - 1;
      //     this.setSourceMark(line, nextText);
      //   }
      // });

      document.addEventListener('click', (event) => {
        console.log('document: click=', event.target);

        if (event.target.id === 'next_doc_button') {
          debugger;
        } else if (event.target.id === 'prev_doc_button') {
          debugger;
        } else if (event.target.classList.contains('doc-button')) {
          const button = event.target;
          document
            .querySelectorAll('.doc-button')
            .forEach((b) => b.classList.remove('doc-button-active'));
          button.classList.add('doc-button-active');
          const fileLineNum = button.id.substring('doc_button_'.length);
          const fileName = fileLineNum.split('_')[0];
          const lineNum = parseInt(fileLineNum.split('_')[1]);
          const file = this._sourceFiles.find((file) => file.name === fileName);
          if (file) {
            const text = file.docs.get(lineNum);
            console.log(
              `doc: fileName='${fileName}', lineNum=${lineNum}, text=`,
              text
            );
            this.setSourceMark(lineNum - 1, text);
          }
        }
      });
    }
  }

  async loadToc() {
    let response = await fetch('/bin/file.cgi', {
      headers: { 'Content-Type': 'application/json' },
    });
    let json = await response.json();
    console.log(json);
  }

  async load(prefix) {
    console.log('Editor.load: prefix=', prefix);
    let page = ZigRun.toc.find((page) => page.file.startsWith(`${prefix}_`));
    // console.log(page);
    // clear tabs
    this._fileId = null;
    this._sourceFiles.splice(0, this._sourceFiles.length); // clear _sourceFiles
    const sourceTabs = document.querySelectorAll('.source-tab');
    sourceTabs.forEach((el) => {
      if (el.id !== 'tab') el.remove();
    });
    // set example name
    document.getElementById('introduction_name').textContent = page.name;
    document.getElementById('editor_name').textContent = page.name;
    //
    let response = await fetch(`/src/${page.file}`, {
      headers: { 'Content-Type': 'text/plain' },
    });
    let text = await response.text();
    const parts = text.split('//@filename=').map((s) => s.trim());
    for (let part of parts) {
      if (part.length == 0) continue;
      let i = part.indexOf('\n');
      let name = part.substring(0, i);
      let id = 'tab-' + name.replace('.', '-');
      let code = part.substring(i).trim();
      let docs = new Map();
      this._sourceFiles.push({ id, name, code, docs });
    }
    // ensure main.zig is first source file
    this._sourceFiles.sort((a, b) => {
      if (a.name === 'main.zig') return -1;
      if (b.name === 'main.zig') return 1;
      return a.name < b.name;
    });
    console.log(this._sourceFiles);
    this.loadSourceDocs();
    // build tabs
    for (let file of this._sourceFiles) {
      let template = document.getElementById('tab');
      const div = template.content.firstElementChild.cloneNode(true);
      div.id = file.id;
      div.textContent = file.name;
      div.addEventListener('click', () => this.setTab(file.id));
      template.parentElement.appendChild(div);
    }
    // set active tab
    if (this._sourceFiles.length > 0) {
      this.setTab(this._sourceFiles[0].id);
    }
  }

  loadSourceDocs() {
    const docs = document.getElementById('docs');
    // clear docs
    Array.from(docs.children).forEach((el) => el.remove());
    // const docButtons = document.querySelectorAll('.doc-button');
    // docButtons.forEach((el) => el.remove());
    //
    for (let file of this._sourceFiles) {
      this.readSourceDocs(file);
      console.log('loadSourceDocs: docs=', file.docs);
    }
    // build doc buttons
    let first = true;
    for (const file of this._sourceFiles) {
      if (!first) {
        docs.insertAdjacentHTML(
          'beforeend',
          `<span class="mr-2">&bull;</span>`
        );
      }
      for (const lnum of file.docs.keys()) {
        const id = `doc_button_${file.name}_${lnum}`;
        const text = file.docs.get(lnum);
        console.log(`doc: id=${id}, text=${text}`);
        docs.insertAdjacentHTML(
          'beforeend',
          `<span id="${id}" class="doc-button">${lnum}</span>`
        );
        first = false;
      }
    }
    // build previous and next buttons
    if (!first) {
      docs.insertAdjacentHTML(
        'afterbegin',
        `
        <svg id="next_doc_button" class="feather svg-button mr-2" alt="prev doc">
          <use xlink:href="/lib/feather-4.28.0/feather-sprite.svg#arrow-right" />
        </svg>      
        `
      );
      docs.insertAdjacentHTML(
        'afterbegin',
        `
        <svg id="prev_doc_button" class="feather svg-button mr-2" alt="prev doc">
          <use xlink:href="/lib/feather-4.28.0/feather-sprite.svg#arrow-left" />
        </svg>      
        `
      );
    }
  }

  readSourceDocs(file) {
    console.log('readSourceDocs: file=', file);
    let code = [];
    let docs = new Map();
    let lineNum = 1;
    for (let line of file.code.split('\n')) {
      // console.log('line=', line);
      if (line.startsWith('//!') || line.startsWith('///')) {
        if (!docs.has(lineNum)) docs.set(lineNum, '');
        let doc = docs.get(lineNum);
        doc += `${line}\n`;
        docs.set(lineNum, doc);
      } else {
        code.push(line);
        lineNum += 1;
      }
    }
    file.code = code.join('\n');
    file.docs = docs;
  }

  setTab(id) {
    const newFile = this._sourceFiles.find((file) => file.id === id);
    if (newFile) {
      if (this._fileId != null) {
        const oldFile = this._sourceFiles.find(
          (file) => file.id === this._fileId
        );
        oldFile.code = this._sourceCodeMirror.getValue();
        const div = document.getElementById(this._fileId);
        div.classList.remove('source-tab-active');
      }
      this._fileId = newFile.id;
      this._sourceCodeMirror.setValue(newFile.code);
      this._sourceCodeMirror.refresh();
      const div = document.getElementById(this._fileId);
      div.classList.add('source-tab-active');
    }
  }

  getSelectedFileName() {
    const file = this._sourceFiles.find((file) => file.id === this._fileId);
    if (file) return file.name;
    throw new Error('no selected file');
  }

  setSelectedFileSource(source) {
    const file = this._sourceFiles.find((file) => file.id === this._fileId);
    if (file) {
      file.code = source;
      this._sourceCodeMirror.setValue(file.code);
      return;
    }
    throw new Error('no selected file');
  }

  setSourceMark(line, text) {
    this._sourceMarks.forEach((mark) => mark.clear());
    this._sourceMarks.splice(0, this._sourceMarks.length);
    this._sourceMarks.push(
      this._sourceCodeMirror.markText(
        { line: line, ch: 0 },
        { line: line, ch: 80 },
        { className: 'source-highlight' }
      )
    );
    this._outputCodeMirror.setValue(text);
  }

  async command(command) {
    this._outputCodeMirror.setValue('');
    if (this._fileId != null) {
      const file = this._sourceFiles.find((file) => file.id === this._fileId);
      file.code = this._sourceCodeMirror.getValue();
    }
    let files = [];
    for (let file of this._sourceFiles) {
      files.push(`//-- ${file.name} --//`);
      files.push(file.code);
    }
    let response = await fetch('/bin/play.cgi', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        command: command,
        filename: command === 'run' ? 'main.zig' : this.getSelectedFileName(),
        source: files.join('\n'),
        output: '',
      }),
    });
    if (response.status === 200) {
      let json = await response.json();
      console.log(json);
      if (command === 'fmt') {
        this.setSelectedFileSource(json.source);
      } else {
        // command === run || command === test
        this._outputCodeMirror.setValue(json.output);
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

const editor = new Editor();
window.ZigRun.editor = editor;

editor.loadToc();
// window.ZigMoe.editor.load('100');
console.log('ready!');