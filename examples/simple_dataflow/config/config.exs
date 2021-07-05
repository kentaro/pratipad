import Config

config :pratipad,
  broadway: [
    forward: [
      producer: [
        module:
          {OffBroadwayOtpDistribution.Producer,
           [
             mode: :push,
             receiver: [
               name: :off_broadway_otp_distribution_receiver
             ]
           ]}
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        default: [concurrency: 1, batch_size: 3]
      ]
    ]
  ],
  dataflow: SimpleDataflow.Dataflow
