pipelineJob('wordpress-docker') {
    definition {
        cpsScm {
            scm {
                github('ukhc/wordpress-docker', 'master', 'https')
            }
        }
    }
}