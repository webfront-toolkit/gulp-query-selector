
fs = require 'fs'
should = require 'should'
gulp = require 'gulp'
tmp = require 'tmp'
assert = require 'stream-assert'
itis = require 'funsert'

delete require.cache[ require.resolve '../' ]

querySelector = require '../'

describe "gulp-query-selector", ->

	src = []

	before ->
		src.push file = tmp.fileSync prefix: 'query-selector'
		fs.writeFileSync file.name, '<parent><child>first</child></parent><parent></parent>'
		src.push file = tmp.fileSync prefix: 'query-selector'
		fs.writeFileSync file.name, '<parent><child>first</child><child>second</child></parent>'
		src.push file = tmp.fileSync prefix: 'query-selector'
		fs.writeFileSync file.name, '<parent><child>first</child><child>second</child><child>third</child></parent>'
	after ->
		while src.length
			src.shift().removeCallback()

	it 'should select all <parent> elements from source files', (done) ->
		gulp.src(src.map (file) -> file.name)
			.pipe querySelector 'parent'
			.pipe assert.length 4
			.pipe assert.nth 0, itis.ok (result) ->
				String(result.contents).should.be.eql '<parent><child>first</child></parent>'
			.pipe assert.nth 1, itis.ok (result) ->
				String(result.contents).should.be.eql '<parent></parent>'
			.pipe assert.nth 2, itis.ok (result) ->
				String(result.contents).should.be.eql '<parent><child>first</child><child>second</child></parent>'
			.pipe assert.nth 3, itis.ok (result) ->
				String(result.contents).should.be.eql '<parent><child>first</child><child>second</child><child>third</child></parent>'
			.pipe assert.end done

	it 'should select all <child> elements from source files', (done) ->
		gulp.src(src.map (file) -> file.name)
			.pipe querySelector 'child'
			.pipe assert.length 6
			.pipe assert.nth 0, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>first</child>'
			.pipe assert.nth 1, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>first</child>'
			.pipe assert.nth 2, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>second</child>'
			.pipe assert.nth 3, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>first</child>'
			.pipe assert.nth 4, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>second</child>'
			.pipe assert.nth 5, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>third</child>'
			.pipe assert.end done

	it 'should produce proper file names', (done) ->
		sourceFiles = src.map (file) -> file.name

		gulp.src sourceFiles
			.pipe querySelector '*'
			.pipe assert.length 19
			.pipe assert.nth 0, itis.ok (result) ->
				result.path.should.be.eql (sourceFiles[0] + '.selection-0000.html')
			.pipe assert.nth 1, itis.ok (result) ->
				result.path.should.be.eql (sourceFiles[0] + '.selection-0001.html')
			.pipe assert.nth 18, itis.ok (result) ->
				result.path.should.be.eql (sourceFiles[2] + '.selection-0006.html')
			.pipe assert.end done

	it 'should group selections by source file', (done) ->
		sourceFiles = src.map (file) -> file.name

		gulp.src sourceFiles
			.pipe querySelector 'child'
			.pipe querySelector.groupBySource()
			.pipe assert.length 3
			.pipe assert.nth 0, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>first</child>'
				result.path.should.be.eql sourceFiles[0]
			.pipe assert.nth 1, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>first</child>\n<child>second</child>'
				result.path.should.be.eql sourceFiles[1]
			.pipe assert.nth 2, itis.ok (result) ->
				String(result.contents).should.be.eql '<child>first</child>\n<child>second</child>\n<child>third</child>'
				result.path.should.be.eql sourceFiles[2]
			.pipe assert.end done

