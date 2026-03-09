from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["users"])


@router.get(
    "/",
    summary="Retrieve all users paginated",
)
async def get_clients() -> str:
    return "This is the paginated list of users"
