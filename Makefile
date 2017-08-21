
all: pipeline-template-json pipeline-datastore-view-rules

clean:
	rm -f *.pyc

test-sanity:
	$(eval PB_TOOL_CONTRACT_DIR := `readlink -f registered-tool-contracts`)
	$(eval PB_PIPELINE_TEMPLATE_DIR := `readlink -f resolved-pipeline-templates`)
	$(eval PB_CHUNK_OPERATOR_DIR := `readlink -f chunk_operators`)
	PB_TOOL_CONTRACT_DIR=$(PB_TOOL_CONTRACT_DIR) \
		PB_PIPELINE_TEMPLATE_DIR=$(PB_PIPELINE_TEMPLATE_DIR) \
		PB_CHUNK_OPERATOR_DIR=$(PB_CHUNK_OPERATOR_DIR) \
		python -c "import pbsmrtpipe.loader as L; L.load_all()"
	PB_TOOL_CONTRACT_DIR=$(PB_TOOL_CONTRACT_DIR) \
    PB_PIPELINE_TEMPLATE_DIR=$(PB_PIPELINE_TEMPLATE_DIR) \
		PB_CHUNK_OPERATOR_DIR=$(PB_CHUNK_OPERATOR_DIR) \
		python -c "import pbsmrtpipe.loader as L; L.load_and_validate_chunk_operators()"
	PB_TOOL_CONTRACT_DIR=$(PB_TOOL_CONTRACT_DIR) \
    PB_PIPELINE_TEMPLATE_DIR=$(PB_PIPELINE_TEMPLATE_DIR) \
    PB_CHUNK_OPERATOR_DIR=$(PB_CHUNK_OPERATOR_DIR) \
		nosetests --verbose pbsmrtpipe.tests.test_pb_pipelines_sanity

jsontest:
	$(eval JSON := `find . -type f -name '*.json' -not -path '*/\.*' | grep -v './repos/' | grep -v './jobs-root/' | grep -v './tmp/' | grep -v 'target/scala'`)
	@for j in $(JSON); do \
		echo $$j ;\
		python -m json.tool $$j >/dev/null || exit 1 ;\
	done

pipeline-template-json:
	python make_pipeline_json.py

pipeline-datastore-view-rules:
	$(eval PB_TOOL_CONTRACT_DIR := `readlink -f registered-tool-contracts`)
	$(eval PB_PIPELINE_TEMPLATE_DIR := `readlink -f resolved-pipeline-templates`)
	PB_TOOL_CONTRACT_DIR=$(PB_TOOL_CONTRACT_DIR) \
		PB_PIPELINE_TEMPLATE_DIR=$(PB_PIPELINE_TEMPLATE_DIR) \
		python pb_pipeline_view_rules.py --output-dir pipeline-datastore-view-rules
