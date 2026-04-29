from enum import Enum


class CommitmentStatus(Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    FAILED = "failed"
