import lf from 'lovefield'

# Use yaml to build schema
# https://groups.google.com/forum/#!topic/lovefield-users/jxIlb7jtiak

schemaBuilder = lf.schema.create('bumblr-database', 1)

schemaBuilder.createTable('Blog')
.addColumn('name', lf.Type.STRING)
.addColumn('content', lf.Type.OBJECT)
.addPrimaryKey(['name'])

export default schemaBuilder

