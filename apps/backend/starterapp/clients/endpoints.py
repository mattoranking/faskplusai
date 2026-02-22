from fastapi import APIRouter

router = APIRouter(prefix="/clients", tags=["clients"])


@router.get(
    "/",
    summary="Retrieve all clients paginated",
)
async def get_clients() -> str:
    return "This is the paginated list of clients"
