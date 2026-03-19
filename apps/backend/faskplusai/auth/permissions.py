import json

import redis.asyncio as redis

from faskplusai.config import settings

_redis: redis.Redis | None = None


async def get_redis() -> redis.Redis:
    global _redis
    if _redis is None:
        _redis = redis.from_url(
            settings.REDIS_URL,
            decode_responses=True,
        )
    return _redis


async def get_permissions_for_roles(
    roles: list[str],
) -> set[str]:
    """Fetch permissions for a list of roles from Redis."""
    r = await get_redis()
    permissions: set[str] = set()
    for role in roles:
        cached = await r.get(f"role:{role}:permissions")
        if cached:
            permissions.update(json.loads(cached))
        else:
            # Cache miss - load from DB then cache
            perms: set[str] = await _load_permissions_from_db(role)
            await r.set(
                f"role:{role}:permissions",
                json.dumps(list(perms)),
                ex=300,  # 5 min TTL
            )
            permissions.update(perms)
    return permissions


async def _load_permissions_from_db(role_name: str) -> set[str]:
    """Fallback: query DB and populate Redis."""
    from faskplusai.sql import select

    from faskplusai.models.role import (
        Permission,
        Role,
        RolePermission,
    )

    from faskplusai.postgres import create_async_engine

    engine = create_async_engine("faskplusai")
    from sqlalchemy.ext.asyncio import async_sessionmaker

    session_factory = async_sessionmaker(bind=engine)
    async with session_factory() as session:
        stmt = (
            select(Permission.name)
            .join(RolePermission)
            .join(Role)
            .where(Role.name == role_name)
        )
        result = await session.execute(stmt)
        return {row[0] for row in result.all()}


async def invalidate_role_cache(role_name: str) -> None:
    """Call this when role permissions are updated."""
    r = await get_redis()
    await r.delete(f"role:{role_name}:permissions")
