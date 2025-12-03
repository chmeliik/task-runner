import re
from typing import Literal, Self, assert_never

VERSION_RE = re.compile(r"\d+(\.\d+)+")


class Version(tuple[int, ...]):
    """Represents the dot-separated numbers at the beginning of a version string.

    E.g.
        0.1            -> 0.1.0
        0.1.2          -> 0.1.2
        0.1.2.3        -> 0.1.2.3
        0.1.2.3-4.el10 -> 0.1.2.3
    """

    def __str__(self) -> str:
        return ".".join(map(str, self))

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}({super().__repr__()})"

    @classmethod
    def parse(cls, s: str) -> Self:
        match = VERSION_RE.match(s)
        if not match:
            raise ValueError(s)
        return cls(map(int, match.group().split("."))).pad(3)

    @property
    def major(self) -> int:
        return self[0]

    @property
    def minor(self) -> int:
        return self[1]

    @property
    def patch(self) -> int:
        return self[2]

    def bump(self, what: Literal["major", "minor", "patch"]) -> Self:
        cls = type(self)
        match what:
            case "major":
                return cls((self.major + 1, 0, 0))
            case "minor":
                return cls((self.major, self.minor + 1, 0))
            case "patch":
                return cls((self.major, self.minor, self.patch + 1))
            case _:
                assert_never(what)

    def pad(self, length: int) -> Self:
        if len(self) < length:
            cls = type(self)
            return cls(self + (0,) * (length - len(self)))
        else:
            return self
