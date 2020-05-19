import Alamofire

public class PSTrustedSession: Session {
    convenience init(interceptor: RequestInterceptor, hosts: [String]) {
        let evaluator = PublicKeysTrustEvaluator(
            keys: Self.generateKeys(),
            performDefaultValidation: true,
            validateHost: true
        )
        let evaluators = hosts.reduce(into: [String: PublicKeysTrustEvaluator]()) { $0[$1] = evaluator }
        let serverTrustManager = ServerTrustManager(evaluators: evaluators)
        self.init(interceptor: interceptor, serverTrustManager: serverTrustManager)
    }
    
    private static func generateKeys() -> [SecKey] {
        let certs = [
        "MIIFzDCCBLSgAwIBAgIRANALh6RcT5svyASekRy/6GUwDQYJKoZIhvcNAQELBQAwgZYxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMTwwOgYDVQQDEzNDT01PRE8gUlNBIE9yZ2FuaXphdGlvbiBWYWxpZGF0aW9uIFNlY3VyZSBTZXJ2ZXIgQ0EwHhcNMTUwNTE4MDAwMDAwWhcNMTgwMjEyMjM1OTU5WjCBrDELMAkGA1UEBhMCTFQxDjAMBgNVBBETBTA0MzI2MRAwDgYDVQQIEwdWaWxuaXVzMRAwDgYDVQQHEwdWaWxuaXVzMRUwEwYDVQQJEwxNZW51bGlvIGcuIDcxHzAdBgNVBAoTFkVWUCBJbnRlcm5hdGlvbmFsLCBVQUIxGTAXBgNVBAsTEFNHQyBTU0wgV2lsZGNhcmQxFjAUBgNVBAMUDSoucGF5c2VyYS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDIjEftNV7qAhRQiKUDiD9UEMh03GcBPsxcWk6atOdHgEV0SzJCIRJE3DwAorBjZp9c86x0FxoTub9ORxoFnEEEW1sFHsGWrZKPpkqcCYdR9OoT0bWjrBMngBeGfgv36TquDjlpmAnnrb439kzYlHhs9l3HKxmmuLeixXzfbSfqT+LsN3DV8YhWlk7RZ/CuoEW8cGbNxJVNV+Mg9Gp+sgOuEYGWgvPldZGtwfj3Y2mu8BtbBdoysddg/TntQvfOB7359rvVANTcHqyFmUQ9dYXUQiisHFdayxFchq1bdDk7hhV9qYrF8nOPYfUToYSa7AjGw6Xayx/V+rbPWQaRH/MlAgMBAAGjggH7MIIB9zAfBgNVHSMEGDAWgBSa8yvaz61Pti+7KkhIKhK3G0LBJDAdBgNVHQ4EFgQUCmNGDHlqTQGe0QMXbY4rbj2u6L0wDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwNAYDVR0lBC0wKwYIKwYBBQUHAwEGCCsGAQUFBwMCBgorBgEEAYI3CgMDBglghkgBhvhCBAEwUAYDVR0gBEkwRzA7BgwrBgEEAbIxAQIBAwQwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLmNvbS9DUFMwCAYGZ4EMAQICMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0NPTU9ET1JTQU9yZ2FuaXphdGlvblZhbGlkYXRpb25TZWN1cmVTZXJ2ZXJDQS5jcmwwgYsGCCsGAQUFBwEBBH8wfTBVBggrBgEFBQcwAoZJaHR0cDovL2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBT3JnYW5pemF0aW9uVmFsaWRhdGlvblNlY3VyZVNlcnZlckNBLmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMCUGA1UdEQQeMByCDSoucGF5c2VyYS5jb22CC3BheXNlcmEuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQADYD4oFC09mXCbYx924bOw//eOPUGqw1Sgyk54A49Ct5ZnyRkDukzQv1fY2gV/HJELBIQS8r6swnmospOyT/KJN0WaKp3hIriG6YxppC00FI/16W0vTJycSg0H0FQ/nIT+awIshJKEtMb3iDK5p73eNu3k8zjBiYWkoa/lBsBy3Ypyy2ZywqkLD0fj7CbW7BQI0pKLbnetkgoO2RJedPt7NwC2tHHdwrOi1JIReW03tpeHhO+RiT2DMNICJIK9U6rxpMzgv7Zt5hzFBBXJKBPDrqgziS0kYKShthFBTuqevYO7HjeefBAx47Alm3sykhJg5pQXi2Q9+S7IKPuzGaJD",
        "MIIDvzCCAqegAwIBAgIJAN/S/Y43s259MA0GCSqGSIb3DQEBCwUAMHYxCzAJBgNVBAYTAkxUMRAwDgYDVQQIDAdWaWxuaXVzMRAwDgYDVQQKDAdQYXlzZXJhMUMwQQYDVQQDDDpDZXJ0aWZpY2F0ZSB3aXRoIGJhY2t1cCBwcml2YXRlIGtleSBmb3Igd2FsbGV0LnBheXNlcmEuY29tMB4XDTE3MTEwOTA5MTgwOFoXDTM3MTEwNDA5MTgwOFowdjELMAkGA1UEBhMCTFQxEDAOBgNVBAgMB1ZpbG5pdXMxEDAOBgNVBAoMB1BheXNlcmExQzBBBgNVBAMMOkNlcnRpZmljYXRlIHdpdGggYmFja3VwIHByaXZhdGUga2V5IGZvciB3YWxsZXQucGF5c2VyYS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTSQE4ARxxZlb1Z7Hs+fZBilK3wY7F1PhiRX0w6PeN6b8lhR++LRfcS90Pd3pwkgsau2KfiXm5Mv8VldhnQ2EAszHH7S6twFZEORxSd2hE4oZbGTZKvzXtsr7dSecQk3sLpQb3tGZIm0KX2k+tdBvzEA1NayMsxF2FNL09B6aTmB8BBF0/0lp4Qj/idLw0fPMQ+8amt6FZcg9e9ymuhpHCpHbSs/ZADL+1JyUNcyo+wpvP3e3gzpE4tFxDl5elukMW88ghS0YRyu8kH/fcvTR9vWiaWbKQgU+FJecC5Hl6X5uKvdrYK1eCHerWJ/2EKVhVoW4agt6eIoaMzkiyWd1pAgMBAAGjUDBOMB0GA1UdDgQWBBRBbcB0+z0mWd/xJQJpYiqI6Rr6ujAfBgNVHSMEGDAWgBRBbcB0+z0mWd/xJQJpYiqI6Rr6ujAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAMMSzcLhTXSJgrFTxLntdDjW38qNAw/HmHDbH9YIQ7c9Qg/c7b+eH7It+Zx4pqCQY9VZyOsgewMdiAIB+RB7cKrTQ+UWZ31D8wrapKrCNOzs4wng2USkTbKQakZcFUCyW42dBfjf7hfaMuF6VxfJS2UJ8wLvyWx+IqnIgzPHkO6Gy4e8N1hylU2DfUJnBBoIatqSYSWlC810gw3tVN9zf9wvjQV+4XKbq1F1BEadeGNEb9z3lbEzEd2jlgN1BTPRN2P8NUXXcCJimv+6WibHaIMlvvscK74AXrfC9cuR2vtF8Dr52mTE/vZFaCtih5AlVL71gTaqp2pXfl1bQoYcGO"
        ]
        
        return certs
            .compactMap { Data(base64Encoded: $0) }
            .compactMap { SecCertificateCreateWithData(nil, $0 as CFData) }
            .compactMap { certificate -> SecKey? in
                var trust: SecTrust?
                let policy = SecPolicyCreateBasicX509()
                let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
                if status == errSecSuccess, let trust = trust {
                    return SecTrustCopyPublicKey(trust)
                } else {
                    return nil
                }
            }
    }
}
