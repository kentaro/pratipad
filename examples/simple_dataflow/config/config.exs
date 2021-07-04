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
        default: []
      ]
    ]
  ],
  dataflow: SimpleDataflow.Dataflow
