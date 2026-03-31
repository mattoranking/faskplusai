from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from faskplusai.utils.db.models import RecordModel

if TYPE_CHECKING:
    from faskplusai.models.refresh_token import RefreshToken
    from faskplusai.models.role import UserRole


class User(RecordModel):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=False
    )
    password_hash: Mapped[str | None] = mapped_column(String, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Relationships
    roles: Mapped[list["UserRole"]] = relationship(
        back_populates="user", lazy="selectin"
    )

    refresh_tokens: Mapped[list["RefreshToken"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
