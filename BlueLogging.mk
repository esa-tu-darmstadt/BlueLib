ifneq ($(LOG),)
$(foreach X,$(LOG),$(eval RUN_FLAGS+=+LOG_$X))
endif