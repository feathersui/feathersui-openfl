/*
generate-modules.js


Commands:

node generate-modules gen-lib
- This will generate the lib modules and save them under lib/

node generate-modules fix-npm-libs
- This will fix references to openfl and actuate

*/

const _fs = require('fs');
const _path = require('path');
const globby = require('globby');
let DelayFS = init();
let delayFS = new DelayFS(false);

// Settings
const srcDirname = 'src'
const libCjsDirname = 'lib';
const baseDir = '..';

let srcDirPath = _path.resolve(baseDir, srcDirname);
let srcFeathersDirPath = _path.resolve(srcDirPath, 'feathers');
let libCjsDirPath = _path.resolve(baseDir, libCjsDirname);
let libCjsGenDirPath = _path.resolve(libCjsDirPath, '_gen');

// Convert windows paths to posix paths
srcDirPath = normalizePath(srcDirPath);
srcFeathersDirPath = normalizePath(srcFeathersDirPath);
libCjsDirPath = normalizePath(libCjsDirPath);
libCjsGenDirPath = normalizePath(libCjsGenDirPath);

const debug = false;

let argv = process.argv;
if (argv.length == 3) {
  start(argv[2]);
} else {
  start(null);
}

async function start(option) {

  output('\n## generate-modules.js...');

  if (option == 'fix-npm-libs') {
    
    // Fix require() calls for OpenFL the cjs modules in the lib/_gen directory
    await startFixNpmLibsGenCjs();
  
    let totalFilesAddedOrModified = writeAllToFileSystem();
  
    output(`\nComplete! ${totalFilesAddedOrModified} files were created or modified`, true);
    process.exit(0);
  }
  else if (option == 'gen-lib') {
    
    // Generate the cjs modules in the lib/ directory
    await startCreateLibCjs();
    
    writeAllToFileSystem();

    // Generate cjs index modules
    await startCreateLibCjsIndexModules();
  
    let totalFilesAddedOrModified = writeAllToFileSystem();
  
    output(`\nComplete! ${totalFilesAddedOrModified} files were created or modified`, true);
    process.exit(0);
  }
  else {
    output('\nOption unrecognized or not specified. Nothing to be done. Exiting script.', true);
    process.exit(1);
  }
  process.exit(0);
}

function writeAllToFileSystem(dryRun) {

  let summary = delayFS.commit(dryRun);
  
  let added = summary.getAdded('cjs-module').length;
  let modified = summary.getModified('cjs-module').length;
  let unmodified = summary.getUnmodified('cjs-module').length;
  if (added > 0 || modified > 0 || unmodified > 0)
    info(`Stats:${libCjsDirname} \n\tfiles added: ${added}, modified: ${modified}, unmodified: ${unmodified}`);
  
  added = summary.getAdded('index').length;
  modified = summary.getModified('index').length;
  unmodified = summary.getUnmodified('index').length;
  if (added > 0 || modified > 0 || unmodified > 0)
    info(`Stats: index.js and index.d.ts \n\tfiles added: ${added}, modified: ${modified}, unmodified: ${unmodified}`);
 
  info('');
  info(`directories created: ${summary.directoriesCreated}`);
  info(`totalCharsWritten: ${summary.totalWritten}`);
  
  let modifiedAll = summary.getModified().length;
  let addedAll = summary.getAdded();
  let unmodifiedAll = summary.getUnmodified();
  let ignoredAll = summary.getIgnored();
  
  if (addedAll.length > 0) {
    if (!dryRun)
      output(`\n${addedAll.length} files created`);
    else {
      
      output(`\n${addedAll.length} files will be created. Some of them:`);
      for (let i = 0; i < 3; i++) {
        output(`${addedAll[i]}`);
      }
    }
  }
  if (unmodifiedAll.length > 0) {
    if (!dryRun)
      output(`\n${unmodifiedAll.length} files were not modified`);
    else
      output(`\n${unmodifiedAll.length} files will not be modified`);
      
  }
  if (ignoredAll.length > 0) {
    
    output(`\nThe following modules are left alone since they contain custom modifications:`);
    output(summary.getIgnored().join('\n'));
    
  }
  if (modifiedAll > 0) {
    if (dryRun) {
      output(`\n${modifiedAll} files will be modified. Here is the list:`);
      //output('\nList of files that will be modified:');
    } else {
      output(`\n${modifiedAll} files modified. Here is the list:`);
      //output('\nList of modified files:');
    }
    output(summary.getModified().join('\n'));
  }



  return summary.totalFilesAddedOrModified;
}


function info(message) {
  if (debug)
    console.log(message);
}


function output(message, lastOutput) {
  console.log.apply(console, [message]);
  
  if (lastOutput)
  console.log('\n## end of generate-modules.js');

}
function error() {
  console.log.apply(console, arguments);
}

function normalizePath(path) {
  let segs = path.split(/[/\\]+/);
  path = segs.join('/');
  return path;
}

function init() {

class DelayFS {
  constructor(debug) {
    this.virtualFileSystem = new Map();
    this.directoriesToCreate = new Map();

    this.debug = debug;
  }


  updateOrAddToVirtualFileSystem(fullFilePath, content, options) {

    if (options == null) {
      options = {};
    }

    let value;
    if (this.virtualFileSystem.has(fullFilePath)) {
      value = this.virtualFileSystem.get(fullFilePath);
    } else {
      value = {};
      this.virtualFileSystem.set(fullFilePath, value);
    }
    
    if (options.readFromRealFileSystem != null && options.readFromRealFileSystem) {
      value.originalContent = content;
    }

    if (options.performWrite) {
      value.performWrite = true;
    }

    if (options.tags != null) {
      if (value.tags != null) {
        value.tags.push(options.tags);
      } else {
        value.tags = [options.tags];
      }
    }
    
    if (options.createOnly != null) {
      value.createOnly = options.createOnly;
    }

    value.content = content;

    //this.log(fullFilePath);
    //this.log(value);
  }


  readFileSyncUTF8(filePath, extra) {

    let fullFilePath = _path.resolve(filePath);

    if (this.virtualFileSystem.has(fullFilePath)) {
      return this.virtualFileSystem.get(fullFilePath).content;
    }

    let content = _fs.readFileSync(fullFilePath, 'utf8');

    let tags = null;
    if (typeof extra == 'string') {
      tags = extra;
    } else if (typeof extra == 'object') {
      if (extra.tags != null)
        tags = extra.tags;
    }
    
    this.updateOrAddToVirtualFileSystem(fullFilePath, content, {readFromRealFileSystem: true, tags: tags});

    return content;
  }



  writeFileSyncUTF8(filePath, content, extra) {

    let fullFilePath = _path.resolve(filePath);

    let createOnly = null;

    let tags = null;
    
    if (typeof extra == 'string') {
      tags = extra;
    } else if (typeof extra == 'object') {
      if (extra.createOnly != null)
        createOnly = extra.createOnly;
      else if (extra.tags != null)
        tags = extra.tags;
    }
    
    this.updateOrAddToVirtualFileSystem(fullFilePath, content, {performWrite: true, tags: tags, createOnly: createOnly});
  }


  commit(dryRun) {
    
    this.directoriesThatExist = new Map();


    let summary = new Summary();

    if (dryRun) {
      //output('Doing dry run...');
    }

    this.directoriesToCreate.forEach((value, key) => {
      // Create all the directories that were requested
      let created = this._mkDirByPathSync(key, dryRun);
      
      summary.directoryCreatedCount(created);
    });


    this.virtualFileSystem.forEach((value, fullFilePath) => {

      // If not null then the file was read from the real file system
      if (value.originalContent != null) {
        summary.readFile(fullFilePath, value.tags);
      }

      // Skip those in which no write was requested
      if (!value.performWrite) {
        return;
      }

      // Check if file we are saving already exists on the file system...
      if (value.originalContent != null || _fs.existsSync(fullFilePath)) {

        let originalContent;

        if (value.originalContent == null) {
          originalContent = _fs.readFileSync(fullFilePath);
        } else {
          originalContent = value.originalContent;
        }

        if (value.content == originalContent) {

          // No modifications made to file 
          summary.unmodifiedFile(fullFilePath, value.tags);

        } else {
          
          // Mofications made to existing file
          if (value.createOnly != null && value.createOnly) {
            summary.unmodifiedFile(fullFilePath, value.tags, true);
            return;
          }

          summary.modifiedFile(fullFilePath, value.tags);
          summary.totalWritten += value.content.length;

          if (dryRun) {
          } else {
            _fs.writeFileSync(fullFilePath, value.content, 'utf8');
          }
        }
      } 
      // ... otherwise we are adding new file
      else {
        
        summary.addedFile(fullFilePath, value.tags);
        summary.totalWritten += value.content.length;

        if (dryRun) {
        } else {
          _fs.writeFileSync(fullFilePath, value.content, 'utf8');
        }

      }
    });

    return summary;
  }

  mkDirByPathSync(targetDir, {isRelativeToScript = false} = {}) {
    this.directoriesToCreate.set(targetDir, true);
  }


  _mkDirByPathSync(targetDir, dryRun, {isRelativeToScript = false} = {}) {
    
    const sep = _path.posix.sep;
    const initDir = _path.isAbsolute(targetDir) ? sep : '';
    const baseDir = isRelativeToScript ? __dirname : '.';

    let directoriesCreated = 0;

    targetDir.split(sep).reduce((parentDir, childDir) => {
      const curDir = _path.resolve(baseDir, parentDir, childDir);

      if (this.directoriesThatExist.has(curDir)) {
        //console.log('exists1', curDir);
        return curDir;
      }


      if (_fs.existsSync(curDir)) {
        //console.log('exists2', curDir);
        this.directoriesThatExist.set(curDir, true);
        return curDir;
      }

      try {
        if (dryRun) {
          //console.log('dryRun - true');
          directoriesCreated++;
        } else {
          //info(curDir);
          _fs.mkdirSync(curDir);
        }
        this.directoriesThatExist.set(curDir, true);
      } catch (err) {
        if (err.code !== 'EEXIST') {
          throw err;
        }
      }
  
      return curDir;
    }, initDir);

    return directoriesCreated;
  }

  log() {
    if (this.debug) {
      console.log.apply(console, arguments);
    }
  }

}

class Summary {


  constructor() {
    this.added = [];
    this.modified = [];
    this.unmodified = [];
    this.read = [];

    this.data = new Map();
    this.directoriesCreated = 0;
    this.totalWritten = 0;
    this.totalFilesAddedOrModified = 0;
  }

  directoryCreatedCount(count) {
    this.directoriesCreated += count;
  }

  readFile(path, tags) {
    this.read.push({tags, path});
  }

  addedFile(path, tags) {
    this.totalFilesAddedOrModified++;
    this.added.push({tags, path});
  }

  modifiedFile(path, tags) {
    this.totalFilesAddedOrModified++;
    this.modified.push({tags, path});
  }

  unmodifiedFile(path, tags, ignored) {
    this.unmodified.push({tags, path, ignored});
  }

  toString() {

    return 'summary';
  }

  getAdded(tags) {

    if (tags == null) {
      return this.added.map(value => value.path);
    }

    return this.added.filter(value => {
      return value.tags && value.tags.some(value => value == tags)

    }).map(value => value.path);
  }

  getModified(tags) {
    if (tags == null) {
      return this.modified.map(value => value.path);
    }

    return this.modified.filter(value => {
      return value.tags && value.tags.some(value => value == tags)
    }).map(value => value.path);
  }

  getUnmodified(tags) {
    if (tags == null) {
      return this.unmodified.map(value => value.path);
    }

    return this.unmodified.filter(value => {
      return value.tags && value.tags.some(value => value == tags)
    }).map(value => value.path);
  }
  
  getIgnored(tags) {
    if (tags == null) {
      return this.unmodified.filter(value => value.ignored).map(value => value.path);
    }

    return this.unmodified.filter(value => {
      return value.tags && value.tags.some(value => value == tags) && value.ignored
    }).map(value => value.path);
  }

  getRead(tags) {
    if (tags == null) {
      return this.read.map(value => value.path);
    }

    return this.read.filter(value => {
      return value.tags && value.tags.some(value => value == tags)
    }).map(value => value.path);
  }
}


return DelayFS;

}

//generate lib and lib-esm

function skipHxPath(path) {
  if(path.indexOf('/macros/') !== -1) {
    return true;
  }
  let symbolName = _path.basename(path);
  symbolName = symbolName.substr(0, symbolName.length - 3);
  let content = _fs.readFileSync(path, 'utf8');
  return content.indexOf(`abstract ${symbolName}(`) !== -1 || content.indexOf(`abstract ${symbolName}<`) !== -1;
}

function startCreateLibCjs() {
  return globby([normalizePath(_path.resolve(srcFeathersDirPath, `**/*.hx`))]).then((paths) => {
    
    for (let path of paths) {
      if(skipHxPath(path)) {
        continue;
      }

      let cjsFilePath = path.replace(srcDirPath + '/', libCjsDirPath + '/').replace('.hx', '.js');
      let cjsGenFilePath = cjsFilePath.replace(libCjsDirPath + '/', libCjsGenDirPath + '/');
      let result = createLibCjsModule(cjsFilePath, cjsGenFilePath);
      // change: "../src/openfl/display/Sprite.hx" to "../lib/openfl/display/Sprite.js"
      
      delayFS.mkDirByPathSync(_path.dirname(cjsFilePath));
      delayFS.writeFileSyncUTF8(cjsFilePath, result, 'cjs-module');
    }
  });
}

function startCreateLibCjsIndexModules() {
  return globby([normalizePath(_path.resolve(libCjsDirPath, 'feathers', '**/*.js'))]).then((paths) => {
    let indexDirPath = normalizePath(_path.resolve(libCjsDirPath, 'feathers'));
    let dirToFiles = {};
    let dirToPackages = {};
    dirToFiles[indexDirPath] = new Set();
    dirToPackages[indexDirPath] = new Set();
    for (let path of paths) {
      if(_path.basename(path) === 'index.js') {
        //skip any existing index files
        continue;
      }

      //add to folder index.js
      let dirName = _path.dirname(path);
      if(!dirToFiles.hasOwnProperty(dirName)) {
        dirToFiles[dirName] = new Set();
      }
      dirToFiles[dirName].add(path);

      let dirNameDirName = _path.dirname(dirName);
      if(!dirToPackages.hasOwnProperty(dirNameDirName)) {
        dirToPackages[dirNameDirName] = new Set();
      }
      dirToPackages[dirNameDirName].add(dirName);
    }

    for (let dir in dirToFiles)
    {
      let filePaths = dirToFiles[dir];
      let result = 'module.exports = {\n';
      for (let path of filePaths)
      {
        result += createFileIndexLine(dir, path);
      }
      let packagePaths = dirToPackages[dir];
      if(packagePaths)
      {
        for (let path of packagePaths)
        {
          result += createPackageIndexLine(dir, path);
        }
      }
      result += "}";
      delayFS.mkDirByPathSync(dir);
      let indexFilePath = _path.resolve(dir, 'index.js');
      delayFS.writeFileSyncUTF8(indexFilePath, result, 'index');
    }
  });
}

function createFileIndexLine(indexDirPath, filePath) {
  let symbolName = _path.basename(filePath);
  symbolName = symbolName.substr(0, symbolName.length - 3);
  let relativePath = normalizePath(_path.relative(indexDirPath, filePath));
  relativePath = relativePath.substr(0, relativePath.length - 3);
  return `\t${symbolName}: require("./${relativePath}").default,\n`;
}

function createPackageIndexLine(indexDirPath, packageDirPath) {
  let symbolName = _path.basename(packageDirPath);
  let relativePath = normalizePath(_path.relative(indexDirPath, packageDirPath));
  return `\t${symbolName}: require("./${relativePath}"),\n`;
}

function createLibCjsModule(cjsPath, cjsGenPath) {
  let relativePath = normalizePath(_path.relative(_path.dirname(cjsPath), cjsGenPath));
  relativePath = relativePath.substr(0, relativePath.length - 3);
  return `module.exports = require("./${relativePath}");`;
}


function startFixNpmLibsGenCjs() {

  return globby([normalizePath(_path.resolve(srcFeathersDirPath, `**/*.hx`))]).then((paths) => {
    
    for (let path of paths) {
      if(skipHxPath(path)) {
        continue;
      }
      let cjsFilePath = path.replace(srcDirPath + '/', libCjsDirPath + '/').replace('.hx', '.js');
      let cjsGenFilePath = cjsFilePath.replace(libCjsDirPath + '/', libCjsGenDirPath + '/');
      let result = processCjsModule(cjsGenFilePath);
      
      delayFS.mkDirByPathSync(_path.dirname(cjsGenFilePath));
      delayFS.writeFileSyncUTF8(cjsGenFilePath, result, 'cjs-module');
    }
  });
}

function processCjsModule(moduleFilePath) {
  let content = _fs.readFileSync(moduleFilePath, 'utf8');

  var libraryNamespaces = ["openfl", "motion"];
  for(let ns of libraryNamespaces)
  {
    let findRequire = new RegExp(`require\\(\"\\.\\/(?:\\.\\.\\/)*${ns}\\/(.*)\"\\)`);
    while(result = content.match(findRequire))
    {
      var newRequire = `require("${ns}").` + result[1].replace(/\//g, ".");
      content = content.substr(0, result.index) + newRequire + content.substr(result.index + result[0].length);
    }

    let findCall = new RegExp(`(${ns}(_\\w+)+\\(\\))\\.default`);
    while(result = content.match(findCall))
    {
      content = content.substr(0, result.index) + result[1] + content.substr(result.index + result[0].length);
    }
  }

  return content;
}