import { mkdir, readdir, readFile, stat, writeFile } from 'node:fs/promises'
import { dirname, basename } from 'node:path'
import { fileURLToPath } from 'node:url'

const ROOT_FOLDER = dirname(fileURLToPath(import.meta.url))
const SRC_FOLTER = ROOT_FOLDER + '/src/'
const OUT_FOLDER = ROOT_FOLDER + '/out/'
const ABI_FOLDER = ROOT_FOLDER + '/abi/'

async function handleFile(file) {
	const filename = file.replace(SRC_FOLTER, '')
	const base = basename(filename)
	const outFilename = OUT_FOLDER + base + '/' + base.replace('.sol', '.json')
	const { abi } = JSON.parse(await readFile(outFilename))
	await writeFile(ABI_FOLDER + base, JSON.stringify(abi, null, '\t'))
}

async function handleDir(dir) {
	const files = await readdir(dir)
	for (const file of files) {
		const path = dir + '/' + file

		if ((await stat(path)).isDirectory()) {
			handleDir(path)
		} else {
			handleFile(path)
		}
	}
}

await mkdir(ABI_FOLDER, { recursive: true })
await handleDir(ROOT_FOLDER + '/src')
